import socket

# 1. Create a socket object (AF_INET = IPv4, SOCK_STREAM = TCP)
dummy_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
dummy_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

# 2. Bind to localhost on a specific port
# Use 127.0.0.1 to keep it internal to your machine
dummy_socket.bind(('127.0.0.1', 65432))

# 3. Listen for incoming connections (1 specifies the backlog queue)
dummy_socket.listen(1)
print("Dummy server is listening on 127.0.0.1:65432...")

try:
    # 4. Accept a connection
    conn, addr = dummy_socket.accept()
    with conn:
        print(f"Connection established from: {addr}")
        
        # 5. Receive and see the incoming data
        while True:
            data = conn.recv(1024)
            if not data:
                break
            print(f"Received data: {data.decode('utf-8')}")
finally:
    dummy_socket.close()

