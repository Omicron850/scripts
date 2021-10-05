import boto3

client = boto3.client('ec2')
response = client.describe_instances(
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': ['{{ tag_value }}']
        }
    ]
)
instancelist = []

for reservation in (response["Reservations"]):
    for instance in reservation["Instances"]:
        print "Found InstanceId that matches Name value: " + instance["InstanceId"]
        instancelist.append(instance["InstanceId"])
# print instancelist

# Stop the instances
 client.stop_instances(InstanceIds=instancelist)
 waiter = client.get_waiter('instance_stopped')
 waiter.wait(InstanceIds=instancelist)

# Change the instance type
 client.modify_instance_attribute(InstanceId=instancelist, Attribute='instanceType', Value='m5.large')

# Start the instance
 client.start_instances(InstanceIds=instancelist)