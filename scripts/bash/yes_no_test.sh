#!/bin/bash

#declare your variable
declare get_q

#Start the while loop to trap the target in the question so they can't avoid the question.
while true; do
#Ask the question
read -e -p "Yes/No/Cancel? (y/n/c)" get_q
#create a case for the question. This is easier than dealing with if statements
    case $get_q in
#Yes to whatever question, it breaks the loop, but doesn't exit.
        [Yy]* ) echo "YES!"; break;;
#No to whatever question, it breaks the loop but does not exit.
#Place break at the last line.
       	[Nn]* ) echo "NO!"; break;;
#Cancels whatever, and exits the loop. Makes the while false.
	[Cc]* ) echo "Cancel!"; exit;;
#doesn't stop anything, it causes it to reask the question!
       	* ) echo "Please answer yes or no.";;
#exit the case
    	esac
#finish the loop
done
