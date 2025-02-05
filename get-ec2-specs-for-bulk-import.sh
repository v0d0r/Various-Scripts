#!/bin/bash

# Description: This script will pull a list of ec2 hosts and root disk devices attached to them. The script assumes you have AWS cli installed and aws profiles configured. Once the details are saved in the csv you can import that and put it into the AWS calculator to auto calculate your EC2 hosts.
# Written by: Kevin Crous
# Last updated: 05/02/2025


# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <profile_name> <region_name>"
    exit 1
fi

# Assign the arguments to variables
PROFILE=$1
REGION=$2

# First, get instance details including Tag:PRODUCT Name, Tag:Name, PlatformDetails, InstanceType, and VolumeId
instance_info=$(aws ec2 describe-instances \
  --profile "$PROFILE" \
  --region "$REGION" \
  --query "Reservations[*].Instances[*].[Tags[?Key=='PRODUCT'].Value | [0], Tags[?Key=='Name'].Value | [0], PlatformDetails, InstanceType, BlockDeviceMappings[0].Ebs.VolumeId]" \
  --output json)

# Get all the unique Volume IDs from the instance_info, filtering out nulls
volume_ids=$(echo "$instance_info" | jq -r '.[].[].[4] | select(. != null)' | tr '\n' ' ')

# Check if volume_ids is not empty
if [ -z "$volume_ids" ]; then
    echo "No valid volumes found for instances. Exiting."
    exit 0
fi

# Debug output for volume_ids
echo "Volume IDs: $volume_ids"

# Get volume details including VolumeId, VolumeType, and Size
volume_info=$(aws ec2 describe-volumes \
  --profile "$PROFILE" \
  --region "$REGION" \
  --volume-ids $volume_ids \
  --query "Volumes[*].[VolumeId, VolumeType, Size]" \
  --output json)

# Parse and combine instance and volume details using jq
combined_output=$(jq -n \
  --argjson instances "$instance_info" \
  --argjson volumes "$volume_info" \
  '[
    ($instances | .[][]) as $instance |
    ($volumes | map(select(.[0] == $instance[4]))[0]) as $volume |
    {
      "Product": $instance[0],
      "Name": $instance[1],
      "OperatingSystem": $instance[2],
      "InstanceType": $instance[3],
      "StorageType": $volume[1],
      "StorageSize(GB)": $volume[2]
    }
  ]'
)

# Output the combined result in CSV format using jq
echo "Product,Name,OperatingSystem,InstanceType,StorageType,StorageSize(GB)"  # CSV Header
echo "$combined_output" | jq -r '.[] | [.Product, .Name, .OperatingSystem, .InstanceType, .StorageType, .["StorageSize(GB)"]] | @csv' | sed 's/Linux\/UNIX/Linux/g'

