#!/bin/sh

set -e
set -o pipefail
set -v

# Configure SSH
mkdir -p "/root/.ssh"
SSH_KEY_PATH="/root/.ssh/ssh_key"
printf "%s" "$SSH_CI_PRIVATEKEY_BASE64" | base64 -d > "$SSH_KEY_PATH"
chmod 0400 "$SSH_KEY_PATH"
echo -e "IdentityFile $SSH_KEY_PATH\\nHost *\\nStrictHostKeyChecking no" >> "/root/.ssh/config"

# Configure Passbolt CLI
printf "%s" "$PASSBOLT_CI_ACS_BASE64" | base64 -d > passbolt_ci_user.acs
go-passbolt-cli configure --serverAddress https://passbolt.infra.com --userPassword "$PASSBOLT_CI_PASSWORD" --userPrivateKeyFile 'passbolt_ci_user.acs'
rm passbolt_ci_user.acs

# Fetch secrets from Passbolt
source fetch_secrets.sh

# Docker login
docker login -u infra -p "$DOCKER_PASSWORD"

# Start deployment
exec $@
