#!/bin/bash
#Created by J.T. Webb on February 05, 2014
#This script creates a user and group.It will take a regular password given by the user and encrypt it,
#as, well as, search for the user, lock the user, unlock the user, delete the user and group.

if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		useradd -m $username
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system"
	exit 2
fi

function validatePassword ()
{
	local stat=1    #Assigns 1 to (stat)
	local pass=$1
	LEN=${#pass}    #Counts each character in the password length
	echo $LEN		#Prints string length
#Check for nums, lowercase, uppercase and checks if password is greater than 8 characters
if [[ $pass =~ [0-9] ]] && [[ $pass =~ [a-z] ]] && {{ $pass =~ [A-Z] ]] && [[ "$LEN" -ge 8 ]]
then
	stat=$?    #Return 1 for false
fi
return $stat
}

function encryptPassword ()
{
	dual=0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZZ0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZZ
	phrase=$encryptedPassword
	rotat=31    #Rotates half of the combined value of 0-10 and sum of upper and lowercase characters
	newphrase=$(echo $phrase | tr "${dual:0:61}" "${dual:${rotat}:61}")
echo "Your encrypted password is ${newphrase}"
}

#Prompts the user for input storing into variable PASSWORD
echo "Your password must be 8 or more characters and include"
echo "both upper and lowercase characters and a number."

#The number of characters will be displayed when password is entered
read -s -p "Enter your password:" -e PASSWORD

passwordToCheck=$PASSWORD
encryptedPassword=$PASSWORD

#Calls function passing value of (PASSWORD)
validatePassword $passwordToCheck

if [[ $? !=1 ]]
then
	echo "Password is valid"
#Calls function passing value of (PASSWORD)
	encryptPassword $encryptedPassword
else
	echo "Invalid Password"
fi
