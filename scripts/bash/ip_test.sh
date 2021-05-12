#!/bin/bash
printf 'Which environment is this for? (qa or prod)'
read env

if [ "$env" == 'qa' ]; then
    EFS_IP="{{ IP_ADDR }}"
    echo "The QA EFS IP is: $EFS_IP"
elif [ "$env" == 'prod' ]; then
    EFS_IP="{{ IP_ADDR }}"
    echo "The Prod EFS IP is: $EFS_IP"
else
    echo " Cancelling..."
    exit 1
fi

set -x
