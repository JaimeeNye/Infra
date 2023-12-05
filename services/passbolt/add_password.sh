#!/bin/sh

echo "Enter passbolt admin password"
read admin_password
go-passbolt-cli configure --serverAddress https://passbolt.infra.com --userPassword "${admin_password}" --userPrivateKeyFile ~/.passbolt_private_admin.acs

echo "Enter resource name"
read resource_name
echo "Enter resource password"
read resource_password
go-passbolt-cli create resource --name "${resource_name}" --password "${resource_password}"
resource_id="$(go-passbolt-cli list resource | grep "${resource_name}" | head -n1 | awk '{print $1}')"
ci_user_id="$(go-passbolt-cli list user | grep "user" | head -n1 | awk '{print $1}')"
go-passbolt-cli share resource --id "${resource_id}" --type 1 --user "${ci_user_id}"

echo "Enter passbolt ci user password"
read ci_user_password
go-passbolt-cli configure --serverAddress https://passbolt.infra.com --userPassword "${ci_user_password}" --userPrivateKeyFile ~/.passbolt_private_ci_user.acs
go-passbolt-cli list resource | grep "${resource_name}" | head -n1
