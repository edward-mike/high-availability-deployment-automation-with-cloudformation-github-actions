#!/bin/bash
# Automation script for CloudFormation templates.
#
# Parameters:
#   $1: Execution mode. Valid values: deploy, delete
#
# Usage examples:
#   ./run.sh deploy
#   ./run.sh delete
#

# Validate parameters
if [[ $1 != "deploy" && $1 != "delete" ]]; then
    echo "ERROR: Incorrect execution mode. Valid values: deploy, delete" >&2
    exit 1
fi

# Set stack names and region
STACK_NAME_VPC="cloudysite"
STACK_NAME_UDAGRAM="projecloudysite-server"
REGION="us-east-1"

# Execute CloudFormation CLI
if [ $1 == "deploy" ]; then
    # Deploy VPC stack
    aws cloudformation deploy \
        --stack-name $STACK_NAME_VPC \
        --template-file network.yml \
        --parameter-overrides file://network-parameters.json \
        --capabilities CAPABILITY_NAMED_IAM \
        --region $REGION

    # Deploy Udagram stack
    aws cloudformation deploy \
        --stack-name $STACK_NAME_UDAGRAM \
        --template-file cloudysite.yml \
        --parameter-overrides file://cloudysite-parameters.json \
        --capabilities CAPABILITY_NAMED_IAM \
        --region $REGION

elif [ $1 == "delete" ]; then
    # Delete Udagram stack
    aws cloudformation delete-stack \
        --stack-name $STACK_NAME_UDAGRAM \
        --region $REGION

    # Delete VPC stack
    aws cloudformation delete-stack \
        --stack-name $STACK_NAME_VPC \
        --region $REGION
fi
