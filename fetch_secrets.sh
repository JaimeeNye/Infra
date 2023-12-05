RESOURCE_LIST="$(go-passbolt-cli list resource)"

fetch_secret() {
    (
    set -e
    set -o pipefail
    SECRET_TO_FETCH="$1"
    # Get passbolt resource ID from passbolt resource name and username
    ID="$(printf "%s" "$RESOURCE_LIST"\
    | grep "${SECRET_TO_FETCH}" | head -n1 | awk '{print $1}')"

    # Get passbolt resource password from its ID
    PASSWORD=$(go-passbolt-cli get resource --id "${ID}" | grep Password | sed 's/^Password: //g')
    echo ${PASSWORD}
    )
}

TF_VAR_cloudflare_token="$(fetch_secret cloudflare_token)"
export TF_VAR_cloudflare_token

TF_VAR_cloudflare_global_api_key="$(fetch_secret cloudflare_global_api_key)"
export TF_VAR_cloudflare_global_api_key
export TF_VAR_dyndns_token="$TF_VAR_cloudflare_global_api_key"

TF_VAR_cloudflare_account_id="$(fetch_secret cloudflare_account_id)"
export TF_VAR_cloudflare_account_id

VULTR_API_KEY="$(fetch_secret vultr_api_key)"
export VULTR_API_KEY

TF_VAR_dyndns_zone_name="$(fetch_secret dyndns_zone_name)"
export TF_VAR_dyndns_zone_name

TF_VAR_admin_password="$(fetch_secret owncloud_admin_password)"
export TF_VAR_admin_password

TF_VAR_owncloud_db_password="$(fetch_secret owncloud_db_password)"
export TF_VAR_owncloud_db_password

AWS_ACCESS_KEY_ID="$(fetch_secret AWS_ACCESS_KEY_ID)"
export AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY="$(fetch_secret AWS_SECRET_ACCESS_KEY)"
export AWS_SECRET_ACCESS_KEY

TF_VAR_gamerpc_mac_address="$(fetch_secret gamerpc_mac_address)"
export TF_VAR_gamerpc_mac_address

TF_VAR_rwol_password="$(fetch_secret rwol_password)"
export TF_VAR_rwol_password

TF_VAR_rcon_password="$(fetch_secret rcon_password)"
export TF_VAR_rcon_password

TF_VAR_sso_password="$(fetch_secret sso_password)"
export TF_VAR_sso_password

TF_VAR_discord_webhook_vultr="$(fetch_secret discord_webhook_vultr)"
export TF_VAR_discord_webhook_vultr

TF_VAR_discord_webhook_homeserver="$(fetch_secret discord_webhook_homeserver)"
export TF_VAR_discord_webhook_homeserver

TF_VAR_discord_webhook_gatus="$(fetch_secret discord_webhook_gatus)"
export TF_VAR_discord_webhook_gatus

TF_VAR_deploy_workflow_token="$(fetch_secret deploy_workflow_token)"
export TF_VAR_deploy_workflow_token

TF_VAR_ru19h_token="$(fetch_secret ru19h_token)"
export TF_VAR_ru19h_token

TF_VAR_homeserver_crowdsec_api_key="$(fetch_secret homeserver_crowdsec_api_key)"
export TF_VAR_homeserver_crowdsec_api_key

TF_VAR_vultr_crowdsec_api_key="$(fetch_secret vultr_crowdsec_api_key)"
export TF_VAR_vultr_crowdsec_api_key

DOCKER_PASSWORD="$(fetch_secret DOCKER_PASSWORD)"
export DOCKER_PASSWORD
export TF_VAR_docker_password="$DOCKER_PASSWORD"
