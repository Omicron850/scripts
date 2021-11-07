#!/usr/bin/env python3
#This script will take a list of IPs from a text file and grab the hostnames

import socket
import sys

file = open('{{ path_to_file', 'r')
lines = file.readlines()
for line in lines:
    #print(line.rstrip())
    addr = socket.gethostbyname(line.rstrip())
    print("IP: %s hostname: %s" %(addr,line.rstrip()))
