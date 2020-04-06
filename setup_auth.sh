#!/bin/sh
echo "Setting environment variables for Terraform"

export ARM_SUBSCRIPTION_ID=<> \n

echo $ARM_SUBSCRIPTION_ID

export ARM_CLIENT_ID=<>\n

echo $ARM_CLIENT_ID

export ARM_CLIENT_SECRET=<>\n

echo $ARM_CLIENT_SECRET

export ARM_TENANT_ID=<>\n

echo $ARM_TENANT_ID

# Not needed for public, required for usgovernment, german, china
export ARM_ENVIRONMENT=public

echo $ARM_ENVIRONMENT
