#!/bin/bash

# Check if profile and region arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <AWS_PROFILE> <AWS_REGION> [append]"
    exit 1
fi

# Assign arguments to variables
PROFILE=$1
REGION=$2
APPEND_FLAG=$3

# Debug flag: Set to 1 for verbose output, 0 for silent mode
DEBUG=1

# Echo the profile and region being used
echo "Starting RDS instance list retrieval"
echo "Profile: $PROFILE"
echo "Region: $REGION"

# Define output CSV file name
OUTPUT_FILE="rds-instances-list-report.csv"

# Check the append flag, and set file mode accordingly
if [ "$APPEND_FLAG" == "append" ]; then
    echo "Appending data to the existing CSV file."
    # Do NOT write headers when appending, just append the data
else
    echo "Overwriting the CSV file."
    # Overwrite the CSV file and add headers
    echo "DBInstanceIdentifier,Engine,EngineVersion,DBInstanceClass,MultiAZ,StorageType,AllocatedStorage,DBInstanceStatus,Company,Product" > "$OUTPUT_FILE"
fi

# Fetch RDS instances data
INSTANCE_DATA=$(aws rds describe-db-instances \
    --query "DBInstances[*].[DBInstanceIdentifier, Engine, EngineVersion, DBInstanceClass, MultiAZ, StorageType, AllocatedStorage, DBInstanceStatus, DBInstanceArn]" \
    --profile "$PROFILE" \
    --region "$REGION" \
    --output text)

# Process each instance and append to the CSV
echo "$INSTANCE_DATA" | while read -r LINE; do
    # Split instance data and ARN
    INSTANCE=$(echo "$LINE" | awk '{print $1","$2","$3","$4","$5","$6","$7","$8}')
    ARN=$(echo "$LINE" | awk '{print $9}')

    # Fetch tags for the instance
    TAGS=$(aws rds list-tags-for-resource \
        --resource-name "$ARN" \
        --profile "$PROFILE" \
        --region "$REGION" \
        --output json)

    # Extract COMPANY and PRODUCT tags
    COMPANY=$(echo "$TAGS" | jq -r '.TagList[] | select(.Key | ascii_downcase == "company") | .Value // empty')
    PRODUCT=$(echo "$TAGS" | jq -r '.TagList[] | select(.Key | ascii_downcase == "product") | .Value // empty')

    # Append the instance data and tags to the CSV
    echo "$INSTANCE,$COMPANY,$PRODUCT" >> "$OUTPUT_FILE"
done

# Conditionally display tabular output based on DEBUG flag
if [ "$DEBUG" -eq 1 ]; then
    echo "Displaying instance data in table format:"
    echo "$INSTANCE_DATA" | while read -r LINE; do
        # Extract details for table output
        INSTANCE=$(echo "$LINE" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8}')
        ARN=$(echo "$LINE" | awk '{print $9}')
        echo "Instance: $INSTANCE (ARN: $ARN)"
    done
fi

echo "The RDS instances have been saved to $OUTPUT_FILE."

