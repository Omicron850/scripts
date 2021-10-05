import boto3
from botocore.client import ClientError

# This section will get all target group arns and put them in a list
client = boto3.client('elbv2')
whole_tg_list = client.describe_target_groups()
arn_list = []

for tg in whole_tg_list['TargetGroups']:
    arn_list.append(tg['TargetGroupArn'])
for arn in arn_list:
    print arn