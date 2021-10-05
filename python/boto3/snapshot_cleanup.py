import boto3
import sys
from botocore.client import ClientError

# This function gets a list of all snapshots with a specific string in the description

def list_snapshots():
  client = boto3.client('ec2')
  whole_list = client.describe_snapshots(
       OwnerIds=[
           '{{ ownder_id }}',
       ],
  )
  snap_list = whole_list['Snapshots']
  keep_list = client.describe_snapshots(
       Filters=[
           {
               'Name': 'description',
               'Values': [
                   '{{ description_value }}',
               ],
           },
       ],
       OwnerIds=[
           '{{ owner_id }}',
       ],
  )
  snap_list_2 = keep_list['Snapshots']

  for snap in snap_list:
      snapshot_id = snap['SnapshotId']
      snapshot_volume = snap['VolumeId']
      if snap not in snap_list_2:
        snap_description = snap['Description']
#      print(snap)
        found = False
        try:
          tags_list = snap['Tags']
        except:
          print "Snapshot has no tags, deleting %s" % snap['SnapshotId']
          delete_snapshot(snap['SnapshotId'], client)
          continue
        for tag in tags_list:
           if ((tag['Key']).lower() == 'preserve' and (tag['Value']).lower() == 'false'):
              print "I'm deleting this snapshots %s" % snap['SnapshotId']
              delete_snapshot(snap['SnapshotId'], client)
              found = True
           elif ((tag['Key']).lower() == 'preserve' and (tag['Value']).lower() == 'true'):
              print "I'm keeping this snapshot %s" % snap['SnapshotId']
        if found == False:
          print "I don't have a preserve tag %s" % snap['SnapshotId']
          delete_snapshot(snap['SnapshotId'], client)

# This function deletes the snapshots
def delete_snapshot(snap, client):
    print "Deleting snapshot %s" % snap
    try:
       client.delete_snapshot(SnapshotId=snap)
    except ClientError, e:
        print str(e)
        print "Failed deleting snapshot %s" % snap

def main():
  list_snapshots()

if __name__ == "__main__": main()
