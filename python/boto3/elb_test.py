import boto3
from botocore.client import ClientError

client = boto3.client('elb')
response = client.describe_load_balancers()

for elb in response['LoadBalancerDescriptions']:
print 'ELB DNS Name : ' + elb['DNSName']