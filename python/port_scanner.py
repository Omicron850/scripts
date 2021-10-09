import socket

#Get the IP and port range to scan from the user
target = input('Enter the IP address to scan: ')
portrange = input('Enter the port range to scan (es 5-2000): ')

lowport = int(portrange.split('-')[0])
highport = int(portrange.split('-')[1])

print('Scanning host ', target, 'from port',lowport, 'to port', highport)

#Try to connet to each port in the range provided.
for port in range(lowport, highport):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    status = s.connect_ex((target, port)) #Returns 0 if the operation succeeded; otherwise, it returns an error code
    if(status == 0):
        print('*** Port',port,'- OPEN ***')
    else:
        print('Port',port,'- CLOSED')
    s.close()