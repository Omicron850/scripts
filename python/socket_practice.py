import socket

SRV_ADDR = input("Type the server IP address: ")
SRV_PORT = int(input("Type the server port: "))

# create a connection
my_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
my_sock.connect((SRV_ADDR, SRV_PORT))
print("Connection established")

# send a message
message = input("Message to send: ")
my_sock.sendall(message.encode())
my_sock.close()