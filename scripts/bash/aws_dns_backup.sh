#!/usr/bin/env bash

set -e

#Parse our arguments
while getopts "b:d:" opt; do
  case $opt in
    b)
      BUCKET_NAME=$OPTARG
      ;;

    d)
      BACKUP_DIR=$OPTARG
      ;;

    ?)
      echo "script usage: $(basename $0) [-b BUCKET_NAME] [-d BACKUP_DIRECTORY]" >&2
      exit 1
      ;;
  esac
done

if [ -z $BUCKET_NAME ] || [ -z $BACKUP_DIR ]
  then
    echo "Missing arguments!  Usage: ./aws-dns-backup.sh -b {BUCKET_NAME} -d {DIRECTORY_NAME}"
    exit -1
fi

#BACKUP_DIR={{ path }}
#BUCKET_NAME={{ bucket_name }}

# Dump all zones to a file and upload to s3
function backup_all_zones () {
  local zones
  # Enumerate all zones
  zones=$(aws route53 list-hosted-zones | jq -r '.HostedZones[].Id' | sed "s/\/hostedzone\///")
  for zone in $zones; do
  RESULT=`aws route53 get-hosted-zone --id $zone | jq .HostedZone.Name --raw-output`
  echo $RESULT
  echo "Backing up zone $zone"
  aws route53 list-resource-record-sets --hosted-zone-id $zone > $BACKUP_DIR/$zone-${RESULT}json
  done

  # Upload backups to s3
  aws s3 cp $BACKUP_DIR s3://$BUCKET_NAME --recursive --sse
}

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR
# Backup up all the things
time backup_all_zones
