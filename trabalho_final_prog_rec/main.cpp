#include <arpa/inet.h>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <exception>
#include <fstream>
#include <iostream>
#include <print>
#include <stdexcept>
#include <string>
#include <sys/socket.h>
#include <unistd.h>
#include <vector>

#define MAX_SAMPLES_PER_PACKET 256
#define FILTER_TAPS 16
constexpr int PORT = 30;

typedef enum {
  MSG_TYPE_INIT_REQ = 0x01,
  MSG_TYPE_INIT_ACK = 0x02,
  MSG_TYPE_AUDIO_REQ = 0x03,
  MSG_TYPE_AUDIO_RES = 0x04,
  MSG_TYPE_ERROR = 0xFF
} MessageType;

typedef struct __attribute__((packed)) {
  uint8_t msg_type;
  uint8_t is_eof;
  uint16_t num_samples;
  uint32_t sequence_num;
  int16_t samples[MAX_SAMPLES_PER_PACKET];
} AudioDataRequest;

typedef struct __attribute__((packed)) {
  uint8_t msg_type;
  uint8_t status_code;
  uint16_t num_samples;
  uint32_t sequence_num;
  int16_t filtered_samples[MAX_SAMPLES_PER_PACKET];
} AudioDataResponse;

typedef struct __attribute__((packed)) {
  uint8_t msg_type;
  uint16_t num_taps;
  int16_t coefficients[FILTER_TAPS];
} FilterConfigRequest;

typedef struct __attribute__((packed)) {
  uint8_t msg_type;
  uint8_t status_code;
} FilterConfigResponse;

const uint16_t PCM = 1;
const uint16_t FLOAT_FORMAT = 3;

enum class WaveFormat : int {
  intPCM_8 = PCM * 8,
  intPCM_16 = PCM * 16,
  intPCM_24 = PCM * 24,
  intPCM_32 = PCM * 32,
  float_32 = FLOAT_FORMAT * 32,
  float_64 = FLOAT_FORMAT * 64,
};

typedef struct {
  char FileTypeBlocID[4];
  uint32_t FileSize;
  char FileFormatID[4];
  char FormatBlocID[4];
  uint32_t BlocSize;
  uint16_t AudioFormat;
  uint16_t NbrChannels;
  uint32_t Frequency;
  uint32_t BytePerSec;
  uint16_t BytePerBloc;
  uint16_t BitsPerSample;
  char DataBlocID[4];
  uint32_t DataSize;
} WavHeader;

typedef struct WavHeaderSafe {
  WavHeaderSafe(WavHeader &unsafe) : unsafeHeader(unsafe) {
    this->cast_to_safe(unsafe);
  }

  WaveFormat waveFormat;
  WavHeader &unsafeHeader;
  std::string FileTypeBlocID;
  uint32_t FileSize;
  std::string FileFormatID;
  std::string FormatBlocID;
  uint32_t BlocSize;
  uint16_t AudioFormat;
  uint16_t NbrChannels;
  uint32_t Frequency;
  uint32_t BytePerSec;
  uint16_t BytePerBloc;
  uint16_t BitsPerSample;
  std::string DataBlocID;
  uint32_t DataSize;

  void cast_to_safe(WavHeader &unsafe) {
    enum WaveFormat format;

    if (unsafe.AudioFormat == FLOAT_FORMAT) {
      throw std::invalid_argument("Unsupported Audio Format (Float).");
    }

    if (unsafe.BitsPerSample == 24) {
      throw std::invalid_argument("Unsupported Audio Format (24-bit).");
    }

    if (unsafe.AudioFormat == PCM) {
      format = static_cast<WaveFormat>(PCM * unsafe.BitsPerSample);
    } else {
      throw std::invalid_argument("Invalid Audio Format.");
    }

    this->waveFormat = format;
    this->FileTypeBlocID = std::string(unsafe.FileTypeBlocID, 4);
    this->FileSize = unsafe.FileSize;
    this->FileFormatID = std::string(unsafe.FileFormatID, 4);
    this->FormatBlocID = std::string(unsafe.FormatBlocID, 4);
    this->BlocSize = unsafe.BlocSize;
    this->AudioFormat = unsafe.AudioFormat;
    this->NbrChannels = unsafe.NbrChannels;
    this->Frequency = unsafe.Frequency;
    this->BytePerSec = unsafe.BytePerSec;
    this->BytePerBloc = unsafe.BytePerBloc;
    this->BitsPerSample = unsafe.BitsPerSample;
    this->DataBlocID = std::string(unsafe.DataBlocID, 4);
    this->DataSize = unsafe.DataSize;
  }

  void print() {
    std::println("FileTypeBlocID: {}", FileTypeBlocID);
    std::println("FileSize: {}", FileSize);
    std::println("FileFormatID: {}", FileFormatID);
    std::println("FormatBlocID: {}", FormatBlocID);
    std::println("BlocSize: {}", BlocSize);
    std::println("AudioFormat: {}", AudioFormat);
    std::println("NbrChannels: {}", NbrChannels);
    std::println("Frequency: {}", Frequency);
    std::println("BytePerSec: {}", BytePerSec);
    std::println("BytePerBloc: {}", BytePerBloc);
    std::println("BitsPerSample: {}", BitsPerSample);
    std::println("DataBlocID: {}", DataBlocID);
    std::println("DataSize: {}", DataSize);
  }
} WavHeaderSafe;

// ---------------------------------------------------------
// DSP: Geração Flexível de Filtros FIR (Windowed Sinc)
// ---------------------------------------------------------
constexpr double PI = 3.14159265358979323846;

enum class FilterType { LowPass, HighPass, BandPass, Notch };

std::vector<int32_t> createFIRQ31(FilterType type, double fc1_hz, double fc2_hz,
                                  double sampleRate, int taps) {
  std::vector<int32_t> coeffs(taps);
  const double F1 = fc1_hz / sampleRate;
  const double F2 = fc2_hz / sampleRate;
  const int M = taps - 1;

  for (int n = 0; n < taps; ++n) {
    double h = 0.0;
    double n_shift = n - M / 2.0;

    if (n == M / 2) {
      switch (type) {
      case FilterType::LowPass:
        h = 2.0 * F1;
        break;
      case FilterType::HighPass:
        h = 1.0 - 2.0 * F1;
        break;
      case FilterType::BandPass:
        h = 2.0 * (F2 - F1);
        break;
      case FilterType::Notch:
        h = 1.0 - 2.0 * (F2 - F1);
        break;
      }
    } else {
      double pi_val = PI * n_shift;
      double sinc1 = sin(2.0 * PI * F1 * n_shift) / pi_val;
      double sinc2 = sin(2.0 * PI * F2 * n_shift) / pi_val;

      switch (type) {
      case FilterType::LowPass:
        h = sinc1;
        break;
      case FilterType::HighPass:
        h = -sinc1;
        break;
      case FilterType::BandPass:
        h = sinc2 - sinc1;
        break;
      case FilterType::Notch:
        h = sinc1 - sinc2;
        break;
      }
    }

    // Janela de Hamming
    double window = 0.54 - 0.46 * cos(2.0 * PI * n / M);
    h *= window;

    // Escalonamento Q31
    coeffs[n] = static_cast<int32_t>(h * (1LL << 30));
  }

  return coeffs;
}

void extracted(WavHeader &header, std::ifstream &file,
               WavHeaderSafe &headerSafe, const std::string &ipv4,
               const std::string &out_filename, FilterType ftype, double fc1,
               double fc2) {

  switch (headerSafe.waveFormat) {

  case WaveFormat::intPCM_16: {
    std::ofstream out(out_filename, std::ios::binary);
    if (!out.is_open()) {
      throw std::runtime_error("Não foi possível criar o arquivo de saída.");
    }
    out.write(reinterpret_cast<const char *>(&header), sizeof(header));

    // ======================================================================
    // 1. Configuração do Socket TCP
    // ======================================================================
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0)
      throw std::runtime_error("Erro ao criar o socket.");

    struct sockaddr_in serv_addr;
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    if (inet_pton(AF_INET, ipv4.c_str(), &serv_addr.sin_addr) <= 0) {
      close(sock);
      throw std::runtime_error("Endereço IP inválido ou não suportado.");
    }

    std::println("Conectando a {}:{}...", ipv4, PORT);
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
      close(sock);
      throw std::runtime_error("Falha ao conectar no servidor.");
    }
    std::println("Conectado.");

    // ======================================================================
    // 2. FASE DE INICIALIZAÇÃO: Enviar Taps do FIR
    // ======================================================================
    auto coeffsQ31 =
        createFIRQ31(ftype, fc1, fc2, headerSafe.Frequency, FILTER_TAPS);

    FilterConfigRequest initReq;
    initReq.msg_type = MSG_TYPE_INIT_REQ;
    initReq.num_taps = FILTER_TAPS;

    for (int i = 0; i < FILTER_TAPS; ++i) {
      initReq.coefficients[i] = static_cast<int16_t>(coeffsQ31[i] >> 16);
    }

    if (send(sock, &initReq, sizeof(initReq), 0) != sizeof(initReq)) {
      close(sock);
      throw std::runtime_error("Falha ao enviar a configuração do filtro.");
    }

    FilterConfigResponse initRes;
    if (recv(sock, &initRes, sizeof(initRes), MSG_WAITALL) != sizeof(initRes) ||
        initRes.status_code != 0) {
      close(sock);
      throw std::runtime_error(
          "O servidor rejeitou a inicialização do filtro.");
    }

    std::println("Filtro inicializado com sucesso. Enviando áudio...");

    // ======================================================================
    // 3. FASE DE STREAMING: Enviar áudio e receber filtrado
    // ======================================================================
    AudioDataRequest audReq;
    AudioDataResponse audRes;
    uint32_t seq = 0;
    size_t total_sent = 0;

    while (true) {
      file.read(reinterpret_cast<char *>(audReq.samples),
                MAX_SAMPLES_PER_PACKET * sizeof(int16_t));

      std::streamsize bytesRead = file.gcount();
      size_t samplesRead = bytesRead / sizeof(int16_t);

      if (samplesRead == 0 && file.eof()) {
        break;
      }

      audReq.msg_type = MSG_TYPE_AUDIO_REQ;
      audReq.is_eof = file.eof() ? 1 : 0;
      audReq.num_samples = samplesRead;
      audReq.sequence_num = seq++;

      if (send(sock, &audReq, sizeof(audReq), 0) <= 0) {
        throw std::runtime_error("Conexão perdida ao enviar áudio.");
      }

      total_sent += samplesRead * sizeof(int16_t);

      if (recv(sock, &audRes, sizeof(audRes), MSG_WAITALL) <= 0) {
        throw std::runtime_error("Conexão perdida ao receber resposta.");
      }

      out.write(reinterpret_cast<char *>(audRes.filtered_samples),
                audRes.num_samples * sizeof(int16_t));

      if (audReq.is_eof)
        break;
    }

    std::println("Processamento concluído. Total enviado: {} bytes",
                 total_sent);
    close(sock);
    break;
  }
  case WaveFormat::intPCM_32: {
    throw std::runtime_error("Feature intPCM_32 not Implemented.");
  }
  default:
    throw std::runtime_error("Unsupported Wave Format at reading stage.");
  }
}

// ---------------------------------------------------------
// MAIN com processamento de argumentos
// ---------------------------------------------------------
int main(int argc, char *argv[]) {
  if (argc < 6) {
    std::cerr << "Uso: " << argv[0]
              << " <IPv4> <input.wav> <output.wav> <tipo_filtro> <fc1> [fc2]\n";
    std::cerr << "Tipos de filtro permitidos: low-pass, high-pass, band-pass, "
                 "notch\n";
    std::cerr << "Exemplo (Passa-Baixa): " << argv[0]
              << " 192.168.0.137 input.wav output.wav low-pass 1000\n";
    std::cerr << "Exemplo (Passa-Banda): " << argv[0]
              << " 192.168.0.137 input.wav output.wav band-pass 500 2000\n";
    return EXIT_FAILURE;
  }

  std::string ipv4 = argv[1];
  std::string infile = argv[2];
  std::string outfile = argv[3];
  std::string ftype_str = argv[4];

  FilterType ftype;
  double fc1 = 0.0, fc2 = 0.0;

  try {
    fc1 = std::stod(argv[5]);
  } catch (...) {
    std::cerr << "Erro: fc1 inválido.\n";
    return EXIT_FAILURE;
  }

  if (ftype_str == "low-pass") {
    ftype = FilterType::LowPass;
  } else if (ftype_str == "high-pass") {
    ftype = FilterType::HighPass;
  } else if (ftype_str == "band-pass" || ftype_str == "notch") {
    if (argc < 7) {
      std::cerr << "Erro: Filtros band-pass e notch requerem duas frequências "
                   "de corte (fc1 e fc2).\n";
      return EXIT_FAILURE;
    }
    ftype =
        (ftype_str == "band-pass") ? FilterType::BandPass : FilterType::Notch;
    try {
      fc2 = std::stod(argv[6]);
    } catch (...) {
      std::cerr << "Erro: fc2 inválido.\n";
      return EXIT_FAILURE;
    }
    if (fc1 >= fc2) {
      std::cerr << "Erro: Para band-pass e notch, fc1 deve ser estritamente "
                   "menor que fc2.\n";
      return EXIT_FAILURE;
    }
  } else {
    std::cerr << "Erro: Tipo de filtro '" << ftype_str << "' desconhecido.\n";
    return EXIT_FAILURE;
  }

  std::ifstream file(infile, std::ios::binary);
  if (!file.is_open()) {
    std::cerr << "Não foi possível abrir o arquivo de entrada: " << infile
              << "\n";
    return EXIT_FAILURE;
  }

  WavHeader header;
  file.read(reinterpret_cast<char *>(&header), sizeof(header));

  try {
    WavHeaderSafe headerSafe(header);
    headerSafe.print();

    double nyquist = headerSafe.Frequency / 2.0;
    if (fc1 >= nyquist || (argc >= 7 && fc2 >= nyquist)) {
      throw std::invalid_argument(
          "Frequência de corte não pode exceder o limite de Nyquist (metade da "
          "taxa de amostragem).");
    }

    extracted(header, file, headerSafe, ipv4, outfile, ftype, fc1, fc2);

    file.close();
  } catch (std::exception &ex) {
    std::cerr << "Erro: " << ex.what() << std::endl;
    if (file.is_open())
      file.close();
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
