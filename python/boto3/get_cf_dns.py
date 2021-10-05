import boto3
from botocore.client import ClientError

client = boto3.client('cloudformation')
items = ['{{ items }}']
stack = client.describe_stack_resources(
    StackName='{{ stack_name }}',
)
stack_list = stack['StackResources']

for stack in stack_list:
stack_resource = stack['ResourceType']
if 'AWS::Route53::RecordSet' in stack_resource:
#We want to exclude the loadbalancers 
 if 'main' not in stack['PhysicalResourceId'] and 'internal' not in stack['PhysicalResourceId']:
    print stack['PhysicalResourceId']