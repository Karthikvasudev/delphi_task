#!/bin/sh
echo "Setting environment variables for Terraform"

export ARM_SUBSCRIPTION_ID=e6c064af-4de4-4ebc-a459-e193bfe6e9bf \n

echo $ARM_SUBSCRIPTION_ID

export ARM_CLIENT_ID=f0720042-c733-4d7f-a84a-803b3b7df068\n

echo $ARM_CLIENT_ID

export ARM_CLIENT_SECRET=13003584-1682-4634-bab4-f5d68a7f013e\n

echo $ARM_CLIENT_SECRET

export ARM_TENANT_ID=93bb4c86-1f5b-48e6-b8c1-b46d17b15c0a\n

echo $ARM_TENANT_ID

# Not needed for public, required for usgovernment, german, china
export ARM_ENVIRONMENT=public

echo $ARM_ENVIRONMENT