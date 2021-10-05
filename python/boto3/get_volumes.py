import boto3
from datetime import datetime, timedelta

client = boto3.client('ec2')
response = client.describe_volumes()
volume_list = response['Volumes']

for vol in volume_list:
    vol_id = vol['VolumeId']
    vol_state = vol['State']
    if 'available' in vol_state:
        print vol_id, vol_state