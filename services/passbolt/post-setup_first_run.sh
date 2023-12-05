# Register admin by hand
docker exec passbolt su -m -c "/usr/share/php/passbolt/bin/cake passbolt register_user -u corentin0pape@gmail.com -f Corentin -l Pape -r admin" -s /bin/sh www-data

# Register ci user by hand
docker exec passbolt su -m -c "/usr/share/php/passbolt/bin/cake passbolt register_user -u saulunaire@gmail.com -f Coco -l Paps -r user" -s /bin/sh www-data

# Install passbolt cli
go install github.com/passbolt/go-passbolt-cli@latest

# Save creds in file
passbolt configure --serverAddress https://passbolt.infra.com --userPassword 'test' --userPrivateKeyFile 'test.acs'

# Add secrets with cli
## Get ci user id
go-passbolt-cli list users
go-passbolt-cli create resource --name "name" --password 'password'
# Run share script
