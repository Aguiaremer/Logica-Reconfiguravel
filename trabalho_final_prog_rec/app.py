import os
import struct
import socket
import numpy as np
from flask import Flask, render_template, request, redirect, url_for, send_from_directory

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
OUTPUT_FOLDER = 'outputs'
PORT_TCP = 30  # Porta do seu servidor de áudio c++ remoto

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

MSG_TYPE_INIT_REQ = 0x01
MSG_TYPE_AUDIO_REQ = 0x03
MAX_SAMPLES_PER_PACKET = 256
FILTER_TAPS = 16

# ---------------------------------------------------------
# HELPER: Ensure complete TCP packet reception
# ---------------------------------------------------------
def recvall(sock, num_bytes):
    data = bytearray()
    while len(data) < num_bytes:
        packet = sock.recv(num_bytes - len(data))
        if not packet:
            return None  # Server closed the connection
        data.extend(packet)
    return bytes(data)

# ---------------------------------------------------------
# DSP: Geração Flexível de Filtros FIR (Windowed Sinc)
# ---------------------------------------------------------
def create_fir_q31(filter_type, fc1_hz, fc2_hz, sample_rate, taps=16):
    coeffs = np.zeros(taps)
    f1 = fc1_hz / sample_rate
    f2 = fc2_hz / sample_rate
    M = taps - 1
    
    for n in range(taps):
        n_shift = n - M / 2.0
        if n_shift == 0:
            if filter_type == 'low-pass': coeffs[n] = 2.0 * f1
            elif filter_type == 'high-pass': coeffs[n] = 1.0 - 2.0 * f1
            elif filter_type == 'band-pass': coeffs[n] = 2.0 * (f2 - f1)
            elif filter_type == 'notch': coeffs[n] = 1.0 - 2.0 * (f2 - f1)
        else:
            pi_val = np.pi * n_shift
            sinc1 = np.sin(2.0 * np.pi * f1 * n_shift) / pi_val
            sinc2 = np.sin(2.0 * np.pi * f2 * n_shift) / pi_val
            
            if filter_type == 'low-pass': coeffs[n] = sinc1
            elif filter_type == 'high-pass': coeffs[n] = -sinc1
            elif filter_type == 'band-pass': coeffs[n] = sinc2 - sinc1
            elif filter_type == 'notch': coeffs[n] = sinc1 - sinc2
            
        window = 0.54 - 0.46 * np.cos(2.0 * np.pi * n / M)
        coeffs[n] *= window

    coeffs_q31 = (coeffs * (1 << 30)).astype(np.int64)
    coeffs_int16 = (coeffs_q31 >> 16).astype(np.int16)
    return coeffs_int16

# ---------------------------------------------------------
# ROTAS DO SCRIPT WEB
# ---------------------------------------------------------

@app.route('/')
def index():
    input_files = os.listdir(UPLOAD_FOLDER)
    output_files = os.listdir(OUTPUT_FOLDER)
    return render_template('index.html', input_files=input_files, output_files=output_files)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "Nenhum arquivo enviado", 400
    file = request.files['file']
    if file.filename == '':
        return "Nenhum arquivo selecionado", 400
    if file:
        file.save(os.path.join(UPLOAD_FOLDER, file.filename))
        return redirect(url_for('index'))

@app.route('/delete/<folder>/<filename>')
def delete_file(folder, filename):
    target_folder = UPLOAD_FOLDER if folder == 'uploads' else OUTPUT_FOLDER
    path = os.path.join(target_folder, filename)
    if os.path.exists(path):
        os.remove(path)
    return redirect(url_for('index'))

@app.route('/process', methods=['POST'])
def process_audio():
    ipv4 = request.form['ipv4']
    filename = request.form['filename']
    filter_type = request.form['filter_type']
    fc1 = float(request.form['fc1'])
    fc2 = float(request.form.get('fc2', 0) or 0)
    
    input_path = os.path.join(UPLOAD_FOLDER, filename)
    output_path = os.path.join(OUTPUT_FOLDER, "filtered_" + filename)
    
    if not os.path.exists(input_path):
        return "Arquivo não encontrado", 404

    with open(input_path, 'rb') as f_in, open(output_path, 'wb') as f_out:
        header = f_in.read(44)
        f_out.write(header) 
        
        sample_rate = struct.unpack('<I', header[24:28])[0]
        coeffs = create_fir_q31(filter_type, fc1, fc2, sample_rate, FILTER_TAPS)
        
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((ipv4, PORT_TCP))
            
            # 1. Enviar Inicialização do Filtro
            init_packet = struct.pack(f'<BH{FILTER_TAPS}h', MSG_TYPE_INIT_REQ, FILTER_TAPS, *coeffs)
            sock.sendall(init_packet)
            
            # Receber Confirmação (Usando recvall para segurança)
            res = recvall(sock, 2)
            if not res:
                return "Servidor fechou a conexão durante a inicialização", 500
                
            msg_type, status_code = struct.unpack('<BB', res)
            if status_code != 0:
                return f"Servidor rejeitou o filtro. Status: {status_code}", 400
                
            # 2. Streaming de Dados
            seq = 0
            while True:
                data = f_in.read(MAX_SAMPLES_PER_PACKET * 2) 
                if not data:
                    break
                    
                samples_read = len(data) // 2
                is_eof = 1 if len(data) < (MAX_SAMPLES_PER_PACKET * 2) else 0
                
                samples = list(struct.unpack(f'<{samples_read}h', data))
                samples += [0] * (MAX_SAMPLES_PER_PACKET - samples_read) 
                
                req_packet = struct.pack(f'<BBHI{MAX_SAMPLES_PER_PACKET}h', 
                                         MSG_TYPE_AUDIO_REQ, is_eof, samples_read, seq, *samples)
                sock.sendall(req_packet)
                seq += 1
                
                # Receber AudioDataResponse: 520 bytes garantidos com recvall
                res_packet = recvall(sock, 520)
                if not res_packet:
                    break # Conexão caiu ou arquivo terminou
                    
                res_data = struct.unpack(f'<BBHI{MAX_SAMPLES_PER_PACKET}h', res_packet)
                res_num_samples = res_data[2]
                filtered_samples = res_data[4:4+res_num_samples]
                
                f_out.write(struct.pack(f'<{res_num_samples}h', *filtered_samples))
                
                if is_eof:
                    break
                    
        except Exception as e:
            return f"Erro na comunicação Socket: {e}", 500
        finally:
            # Garante que o socket sempre feche, mesmo se houver erro
            sock.close()
            
    return redirect(url_for('index'))

@app.route('/download/<folder>/<filename>')
def download_file(folder, filename):
    target_folder = UPLOAD_FOLDER if folder == 'uploads' else OUTPUT_FOLDER
    return send_from_directory(target_folder, filename)

if __name__ == '__main__':
    # debug=False evita que o Flask reinicie quando o arquivo de áudio for salvo!
    app.run(debug=False, port=5000)
