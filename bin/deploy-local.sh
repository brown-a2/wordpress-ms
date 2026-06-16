#!/bin/bash

# check for the .env file and generate a configmap out of it 
if [[ -a ".env-local" ]]; then
    kubectl create configmap wpconfig --from-env-file=.env-local
else
    echo ".env file is missing, please add, so a configmap can be generated."
    exit
fi

# https://helm.sh/docs/helm/helm_upgrade
#
# This script does the following:
# - installs the chart if it doesn't exist
# - applies the correct environment values
# - creates the namespace if it doesn't exist
# - will time out if there is any issue after 15 minutes
# - uses atomic flag which rolls back changes in the case of a failed upgrade
#
# NOTE: timeout must exceed the worst-case cold image pull. A short timeout
# combined with --atomic rolls back a deploy that is merely waiting on a slow
# first-time image pull, which then "works" on retry once the image is cached.
#
helm upgrade wordpress helm_deploy/wordpress \
    --install \
    --values helm_deploy/wordpress/values-local.yaml \
    --namespace hale-platform-local \
    --create-namespace \
    --timeout 15m \
    --atomic

set -e
