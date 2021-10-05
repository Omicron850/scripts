import boto3
session=boto3.session.Session(profile_name='{{ profile }}')
clxec2=session.resource('ec2')

for inst in clxec2.instances_all():
 print(inst.instance_id)