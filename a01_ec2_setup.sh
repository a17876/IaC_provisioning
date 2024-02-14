#!/bin/bash
set -o nounset

ami_id="ami-04203cad30ceb4a0c"
instance_type="t2.micro"
ssh_key_name="acit_4640"
instance_name="a1_ec2"
# az="us-west-2b"

source state_file.txt

# Create EC2 Instance and store ID
instance_id=$(
    aws ec2 run-instances \
        --image-id $ami_id \
        --instance-type $instance_type \
        --key-name $ssh_key_name \
        --security-group-ids $security_group_id \
        --subnet-id $subnet_id \
        --query 'Instances[*].InstanceId' \
        --output text
        )
        
        # --placement AvailabilityZone=$az \

# Add the Instance Name
aws ec2 create-tags \
    --resources $instance_id \
    --tags Key=Name,Value=$instance_name

echo "$instance_id instance is created"

# Loop to wait for EC2 Instance to come up
aws ec2 wait instance-running --instance-ids "${instance_id}"

#Discover and Record the Public IP Address
ec2_public_ip=$(
    aws ec2 describe-instances \
    --instance-ids "${instance_id}" \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text
    )
echo "ec2_public_ip is $ec2_public_ip"

# Discover and Record the Public Hostname of an EC2 Instance
ec2_dns_name=$(
    aws ec2 describe-instances \
    --instance-ids "${instance_id}" \
    --query 'Reservations[*].Instances[*].PublicDnsName' \
    --output text
    )
echo "ec2_dns_name is $ec2_dns_name"



echo "instance_id=$instance_id" >> state_file.txt
echo "ec2_dns_name=$ec2_dns_name" >> state_file.txt
echo "ec2_public_ip=$ec2_public_ip" >> state_file.txt

echo "Resources are created and stored in state_file."
