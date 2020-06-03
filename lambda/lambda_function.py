import json
import boto3
from botocore.exceptions import ClientError


ec2 = boto3.client('ec2')


def eip_get_first_available(asg_name):
    filters = [
         {'Name': 'tag:AutoScalingGroupName', 'Values': [asg_name]}
    ]
    response = ec2.describe_addresses(Filters=filters)
    print("describe_addresses response", json.dumps(response))
    for eip in response["Addresses"]:
        if "NetworkInterfaceId" in eip:
            print("Already assigned", eip["AllocationId"], "with", eip["InstanceId"])
        else:
            return(eip)
    return None


def eip_attach(instances, asg_name='*'):

    for instanceid in instances:
        myeip = eip_get_first_available(asg_name)
        print("eip_get_first_available", myeip)
        if not myeip:
            print("No EIP available for ASG", asg_name)
            return False

        try:
            print("Affecting", myeip["AllocationId"], "with", instanceid)
            response = ec2.associate_address(AllocationId=myeip['AllocationId'], InstanceId=instanceid, AllowReassociation=True)
            print("associate_address response", json.dumps(response))
            print("Affected", myeip["AllocationId"], "with", instanceid)
        except ClientError as e:
            print(e)

    return True



def lambda_handler(event, context):
    
    # Debug
    print("event:", json.dumps(event))
    
    asg_name = event["detail"]["AutoScalingGroupName"]
    print("Event on ASG", asg_name)
    
    instances = []
    for i in event["resources"]:
        if i.startswith("arn:aws:ec2"):
            instances.append(i.split('/')[1])
            
    if event["detail-type"] == "EC2 Instance Launch Successful":
        print("Associate", instances)
        eip_attach(instances, asg_name)
    
    return
