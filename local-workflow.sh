#!/usr/bin/env bash

# Strict mode, fail on any error
set -euo pipefail

echo ""
echo "Checking environment..."
echo ""

HAS_AZ=$(command -v az || true)
if [ -z "$HAS_AZ" ]; then
    echo "AZ CLI not found"
    echo "please install it as described here:"
    echo "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

HAS_ACT=$(command -v act || true)
if [ -z "$HAS_ACT" ]; then
    echo "ACT not found"
    echo "please install it as described here:"
    echo "https://github.com/nektos/act#installation"
    exit 1
fi

echo "Checking Azure environment..."
echo ""

az account show -o table

local_azure_settings_folder="$HOME/.azure"
act_azure_settings_folder="/root/.azure"
container_options=""

for file in msal_token_cache.json azureProfile.json; do
    local_file="$local_azure_settings_folder/$file"
    if [ ! -s "$local_file" ]; then
        echo "File not found or is empty: $local_file"
        echo "please run `az login`."
        exit 1
    fi
    container_options="$container_options -v $local_azure_settings_folder/$file:$act_azure_settings_folder/$file"
done

echo ""
echo "Running act..."
echo ""

set -x

act \
    --container-architecture linux/amd64 \
    --container-options "$container_options" \
    --var-file .variables \
    --secret-file .secrets \
    $*
