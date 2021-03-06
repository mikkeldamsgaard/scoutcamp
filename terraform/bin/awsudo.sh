#!/usr/bin/env bash
# DEPENDENCIES:
#  - awscli

set -e # Exit on any child process error

ROLE_ARN=$1

if [[ ${ROLE_ARN} =~ ^arn:aws:iam ]]; then
    echo "Using RoleArn: ${ROLE_ARN}"
else
    echo "Invalid role arn provided. Provided value: ${ROLE_ARN}"
    exit 1
fi

# Assume role for running cloud formation
export tokeninfo=`aws sts assume-role --role-arn ${ROLE_ARN} --role-session-name RoleSession --duration-seconds 900 --output=json`

# Set AWS Assumed Role Credentials on ENV
export AWS_SESSION_TOKEN=$( echo $tokeninfo | jq -r .Credentials.SessionToken )
export AWS_ACCESS_KEY_ID=$( echo $tokeninfo | jq -r .Credentials.AccessKeyId )
export AWS_SECRET_ACCESS_KEY=$( echo $tokeninfo | jq -r .Credentials.SecretAccessKey )

