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

local_azure_settings_folder="./.azure.secrets"
act_azure_settings_folder="/root/.azure"

echo ""
echo "Running act..."
echo ""

set -x

act \
    --container-architecture linux/amd64 \
    --container-options "-v $local_azure_settings_folder/:$act_azure_settings_folder/" \
    --var-file .variables \
    --secret-file .secrets \
    $*
