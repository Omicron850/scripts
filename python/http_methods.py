import http.client

print("** This program returns a list of methods if OPTIONS is enable **\n")

host = input("Enter the host/IP: ")
port = input("Enter the port(default:80): ")

if(port == ""):
    port = 80

try:
    connection = http.client.HTTPConnection(host, port)
    connection.request('OPTIONS', '/')
    response = connection.getresponse()
    print("Enabled methods are: ",response.getheader('allow'))
    connection.close()
except ConnectionRefusedError:
    print("Connection failed")
