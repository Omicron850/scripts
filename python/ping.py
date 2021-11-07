#This script will take a list of IPs from a text file and ping them
#to see if they are up or down

import subprocess

file = open('{{ path_to_file }}', "r")

lines = file.readlines()

for line in lines:
   response=subprocess.Popen(['ping', '-c', '1', line.strip()],
   stdout=subprocess.PIPE,
   stderr=subprocess.STDOUT)
   stdout, stderr = response.communicate()
   #print(stdout)
   #print(stderr)

   if (response.returncode == 0):
      status = line.rstrip() + ' is Reachable'
   else:
      status = line.rstrip() + ' is Not reachable'
    print(status)
