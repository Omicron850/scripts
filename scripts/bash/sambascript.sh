#!/bin/bash
#Title: sambascript.sh
#Created by J.T. Webb on February 7, 2014
#For Senior Project Class
#This script will install Samba and configure appropriate settings.

#Declare the variables
declare samba_config
declare user
declare vuser
declare path
declare share
declare pub
#Set the values of the variables
samba_config=/etc/samba/smb.conf
#line="hosts allow ="
user=user
vuser=vuser
path=path
share=share
pub=public
smb_version=`smbd -V`
samba_update=`yum list samba samba-client`
basedir=/home
usershell=/bin/bash
## Declare all the functions first

## function to check if user already exists on system
ifUserExists(){
        grep $1 /etc/passwd > /dev/null
        [ $? -eq 0 ] && return $TRUE || return $FALSE
}

## function to create the user with default shell and home directory passed from below
createNewUser(){
        if /usr/sbin/useradd "$@"
        then echo "User $6 Added"
        fi
}

## function to set the user password
createPassword(){
        if echo -e "$1\n$1\n" | /usr/bin/passwd $2
        then echo "Password Created for User $2"
        fi
}

## function to setup samba user
createNewSambaUser(){
        if (echo $1; echo $1) | /usr/bin/smbpasswd -as $2
        then echo "Samba Account for User $2 Added"
        fi
}

clear
echo "This script will install and configure Samba,"
echo "create a system and Samba user, and configure"
echo "the appropriate settings for SELinux."
sleep 3
echo ""
echo "Hello! How are you today? Which option would you like to do?"
PS3="Please enter your choice: " #Used by select statement to set the text to prompt
options=( "Install Samba" "Update Samba" "Uninstall Samba" "Exit")  #Creates the options array
select opt in "${options[@]}"    #Selects determining value from options array
do
    case $opt in
        "Install Samba") echo "You have chosen to install Samba"
                         read -p "Do you want to continue? " YesNo
                         if [[ $YesNo = "Yes" || $YesNo = "yes" ]]   #Input can be "Yes" or "yes". Case does not matter.
                         then
                            yum install -y samba && yum install -y samba-client
                            echo "Installation of samba and samba-client has been successful!!"
			    sleep 3
                         elif [[ $YesNo = "No" || $YesNo = "no" ]]  #Input can be "No" or "no". Case does not matter.
                         then
                        #Exits the entire script
                        echo "Installation of samba and samba-client failed. Exiting..."
                        exit 1
                        fi
                        break
                        ;;
        "Update Samba") echo "You have chosen to upgrade Samba."
                        echo "Your current Samba version is $smb_version"   #Checks to see which version of Samba is installed
                        echo "These are the available packages you need to update"   #Checks to see which packages are available to update
                        echo $samba_update
                        read -p "Would you like to go ahead and start the update? " YesNo
                        if [[ $YesNo = "Yes" || $YesNo = "yes" ]]
                        then
                            yum update samba && yum up samba-client
			    echo "You are currently running the latest version of Samba."
                        elif [[ $YesNo = "No" || $YesNo = "no" ]]
                        then
                            echo "We will not proceed with the updates."
                        fi
                        break
			exit 1
                        ;;
        "Uninstall Samba") echo "You have chosen to uninstall Samba."
                           read -p "Are you sure you want to delete? " YesNo
                           if [[ $YesNo = "Yes" || $YesNo = "yes" ]]
                           then
                                yum remove -y samba samba-client      #Uninstalls Samba
                                yum remove -y policycoreutils-gui     #Uninstalls SeLinux Management
                                echo ""
                                echo "Samba has been uninstalled"
                                echo ""
                           elif [[ $YesNo = "No" || $YesNo = "no" ]]
                           then
                                echo "Uninstall will not proceed."
                            fi
                            ;;
        "Exit") echo "Will exit..."
                exit
                ;;
        *) echo "Invalid option. Please choose between services [1-4]"
           ;;
    esac
done

clear
echo "SELinux Management must be installed in order"
echo "to set the booleans and file types for the share later on."
read -p "Would you like to continue? " YesNo
if [[ $YesNo = "Yes" || $YesNo = "yes" ]]
then
    #Install SELinux Management
    echo "-----SELinux Management will now install----"
    sleep 3
    yum install -y policycoreutils-gui
    clear
elif [[ $YesNo = "No" || $YesNo = "no" ]]
then
	echo "We will not continue."
	exit 1
fi
echo "With using the lokkit command, the changes to the firewall"
echo "will not be overridden but any changes made using the iptables"
echo "command will be overridden once it's saved."
read -p "Would you like to use the lokkit command or iptables? " LI
case $LI in
    Lokkit|lokkit) lokkit -s samba  #Opens up samba ports
                   lokkit -s samba-client
                   echo ""
                   echo "----Ports have been opened!----"
                   echo ""
                   #Restart iptables
                   service iptables restart
                   sleep 3
                   ;;
    Iptables|iptables)  iptables -A INPUT -m state --state NEW -m udp -p udp --dport 137 -j ACCEPT
                        echo "Port 137 UDP is now open."
                        iptables -A INPUT -m state --state NEW -m udp -p udp --dport 138 -j ACCEPT
                        echo "Port 138 UDP is now open."
                        iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 139 -j ACCEPT
                        echo "Port 139 TCP is now open."
                        iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 445 -j ACCEPT
                        echo "Port 445 TCP is now open."
                        echo ""
                        echo "All of the ports have been opened successfully!"
                        echo ""
                        service iptables save
                        echo "You will now see that the ports have been opened."
                        cat /etc/sysconfig/iptables
                        sleep 3
                        ;;
    *) echo "Sorry, please enter lokkit or iptables in order to continue."
       exit 1
        ;;
esac

clear

echo "To use Samba, the user must exist in both the Samba database and on the system."
echo "This script will create the user in the Samba database and if it does not exist"
echo "on the system it will create the user there as well."
read -p "Is this ok? " reply
case $reply in
      Yes|yes) ## get username from input
    	       read -p "Enter username : " username
               ## if user doesn't exist, add user
               if ( ! ifUserExists $username )
               then
               ## get password from input
               read -s -p "Enter password : " password
               createNewUser -m -b $basedir -s $usershell $username
               createPassword $password $username
               createNewSambaUser $password $username
	       else
                 ## oops, username already being used
                 echo "Username \"$username\" already exists"
                 exit 3
		 fi
                  ;;
       No|no) read -p "Do you only want to create the system user or Samba user? " user
              case $user in
	           System|system) echo "You have chosen to only create a system user."
			          read -p "Enter username : " username
				  if ( ! ifUserExists $username )
               			  then
				  read -s -p "Enter password : " password
				  createNewUser -m -b $basedir -s $usershell $username
			          createPassword $password $username
			          sleep 3
				  fi
				   ;;
	           Samba|samba) echo "You have chosent to only create a Samba user."
			        read -p "Enter username : " username
				  if ( ! ifUserExists $username )
               			  then
				     read -s -p "Enter password : " password
				CreatePassword $password $username
                                createNewSambaUser $password $username
			        sleep 3
			        fi
			        ;;
  esac
esac

clear
echo "A backup of the smb.conf file is being created"
sleep 3
#Make a backup of the smb.conf file
cp --backup /etc/samba/smb.conf /etc/samba/smb.conf.bak

clear
#Get the Workgroup name
read -p "What is your workgroup? " workgroup
echo "Your workgroup is $workgroup"
get_ip=`hostname -I`
while true; do
    read -p "Current IP address is $get_ip, do you wish to change? " yn
    case $yn in
        Yes|yes) read -p "Please enter new IP address: " new_ip
                 echo "hosts allow = $new_ip" >> /etc/samba/smb.conf
                 break
                 ;;
        No|no)  echo "You chose no, so we will stick with $get_ip"
                break
                 ;;
        *) echo "Please enter a Yes or No"
        ;;
    esac
done
#Get the share name
echo -n "What is the share name? "
read $share
#Get the path to the share
echo -n "What is the share path? "
read $path
#Create the share directory
mkdir -p $path
#Set the correct permissions for the directory
chmod 1755 $path
echo "--------Share directory has been created--------"
#Once the directory is created, copy files into it
while true
  do
    read -p "Enter a file to be copied: " target
    cp $target $path
    echo "-------Files have been copied into the directory-------"
    break
  done
while true
do
    clear
    #Creates the smb.conf file from scratch
    echo "PLEASE STAND BY WHILE SMB.CONF FILE IS BEING CONFIGURED"
    sleep 3
    echo "#======================= Global Settings =======================" > /etc/samba/smb.conf
    echo "[global]" >> /etc/samba/smb.conf
    echo "workgroup = WORKGROUP" >> /etc/samba/smb.conf
    echo "hosts allow = $get_ip" >> /etc/samba/smb.conf
    echo "server string = Samba Server Version %v" >> /etc/samba/smb.conf
    echo "wins support = yes" >> /etc/samba/smb.conf
    echo "dns proxy = no" >> /etc/samba/smb.conf

    echo "#### Debugging/Accounting ####" >> /etc/samba/smb.conf
    echo "log file = /var/log/samba/log.%m" >> /etc/samba/smb.conf
    echo "max log size = 1000" >> /etc/samba/smb.conf
    echo "syslog = 0" >> /etc/samba/smb.conf
    echo "panic action = /usr/share/samba/panic-action %d" >> /etc/samba/smb.conf

    echo "####### Authentication #######" >> /etc/samba/smb.conf
    echo "security = user" >> /etc/samba/smb.conf


    echo "#======================= Share Definitions =======================" >> /etc/samba/smb.conf
    echo "[homes]" >> /etc/samba/smb.conf

    echo "comment = Home Directories" >> /etc/samba/smb.conf
    echo "browseable = yes" >> /etc/samba/smb.conf
    echo "guest ok = yes" >> /etc/samba/smb.conf
    echo "read only = no" >> /etc/samba/smb.conf
    echo "create mask = 0775" >> /etc/samba/smb.conf
    echo "directory mask = 0775" >> /etc/samba/smb.conf
    echo "writeable = yes" >> /etc/samba/smb.conf


    echo "[$share]" >> /etc/samba/smb.conf
    echo "path = $path" >> /etc/samba/smb.conf
    echo "guest ok = yes" >> /etc/samba/smb.conf
    echo "browseable = yes" >> /etc/samba/smb.conf
    echo "read only = no" >> /etc/samba/smb.conf
    echo "create mask = 0777" >> /etc/samba/smb.conf
    echo "directory mask = 0777" >> /etc/samba/smb.conf
    echo "writeable = yes" >> /etc/samba/smb.conf
    break
done

#After configuring the smb.conf file, restart Samba services and make the services survive a reboot
while true
do
    clear
    echo "Services are being restarted and chkconfig'd"
    sleep 3
    /etc/init.d/smb restart
    /etc/init.d/nmb restart
    /etc/init.d/winbind restart
    chkconfig smb on
    chkconfig nmb on
    chkconfig winbind on
    break
done

# Set appropriate SELinux labels for the share
if [ $? -eq 0 ]
then
        clear
        echo "Setting SeLinux. This may take a while. Please Stand by."
        chcon -R -t samba_share_t $path
        semanage fcontext -a -t samba_share_t $path
        echo "SELinux has been completed."
else
        echo "Failed to make SELinux changes"
        exit 1
fi
# Set the appropriate SELinux booleans for the share
if [ $? -eq 0 ]
then
        echo "Please be patient as booleans will now be set for the Samba share"
        setsebool -P samba_enable_home_dirs 1
        setsebool -P samba_export_all_rw 1
        echo "-----Booleans have been set successfully-----"
else
        echo "Failed to set booleans"
fi
clear
#Test the share on the host system
smbclient -L $get_ip -U $username
if [ $? -eq 0 ]
then
    echo ""
    echo "Samba has been successfully installed and configured."
        echo "Have a great day!!"
    echo ""
fi
