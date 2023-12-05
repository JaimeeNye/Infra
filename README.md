# Infra
My personal infrastructure. 

## Usage

- bootstrap Terraform (see the [bootstrap folder](./bootstrap/))
- `./deploy.sh` to deploy configuration (can add `-auto-approve` for automated deployments)

## Manual intervention

- Bootstrap Terraform by modifying the backend (first local, then S3)
- Setup the dyndns on [duckdns](https://duckdns.org)
- Wiring the machines and flashing the OSes (except the Vultr one)

## Service deployment

Services are containerized with their configuration files in a Docker image
pushed on Docker Hub, before being deployed on a machine with Terraform.

Configuration changes are (more or less) detected with Terraform.

## Reverse-proxying

I'm using Traefik dynamic configuration capabilities, to have the proxy
configuration in each service's config instead of a global config.

Each machine basically has a Traefik container running, which figures out the
needed proxy configuration using the Docker provider (the Traefik provider).

That way it is easy to move services around, duplicate them and to deploy new
ones and there is only one Traefik service configuration.

## Kubernetes

I think that most of the features above could be managed by Kubernetes,
so in the future I will probably use it.

## Resources

### Machines

- Home Server: okey CPU, lot of storage, not resilient
- Gamer PC Raspi: not resilient, no CPU no storage
- AWS S3 / DynamoDB: very resilient, little storage
- Vultr VPS: okey resilient, bad CPU, not much storage

### DNS servers

- Cloudflare

## Technologies

CI/CD pipeline:

- Terraform: server provisionning and DNS configuration
- Ansible: server configuration
- Docker: containerize apps
- Terraform: deploy apps
- Github actions: run the pipeline

Netdata: monitoring
Dockerhub: storing images to be deployed

## Secrets

The following secrets should be exported in the env:

- TF_VAR_cloudflare_token
- VULTR_API_KEY
- TF_VAR_dyndns_token
- TF_VAR_owncloud_admin_username
- TF_VAR_owncloud_admin_password
- TF_VAR_owncloud_db_password
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- TF_VAR_mosquitto_user
- TF_VAR_mosquitto_password
- TF_VAR_gamerpc_mac_address
- TF_VAR_rcon_password
- TF_VAR_discord_webhook_vultr
- TF_VAR_discord_webhook_homeserver
- TF_VAR_discord_webhook_raspi

Use the `fetch_secrets.sh` script to export them from Passbolt.
The only prerequisite is configuring *go-passbolt-cli* with the proper gpg key and password.

## Architecture

    infra/
    ├─ bootstrap/ # Bootstrapping Terraform (save tfstate on AWS)
    ├─ machines/ # Contains machine declarations
    │  ├─ init.tf
    │  ├─ main.tf # Call the machines' modules
    │  ├─ output.tf # Variables required for setting-up the services (DynDNS domains, ports, ...)
    │  ├─ variables.tf # Variables needed to deploy machines
    │  ├─ vultr/
    │  │  ├─ ansible/ # Ansible configuration
    │  │  │  ├─ playbook.yml
    │  │  │  ├─ inventory.yml
    │  │  │  ├─ ansible_script.sh
    │  │  ├─ configure.tf # Use Ansible to configure the machine, with Terraform to detect configuration changes
    │  │  ├─ outputs.tf # DynDNS domain to avoid variable declaration repeatition
    │  │  ├─ variables.tf # Inputs variable (DNS token mostly)
    │  ├─ homeserver/
    │  │  ├─ ansible/
    │  │  │  ├─ playbook.yml
    │  │  │  ├─ inventory.yml
    │  │  │  ├─ ansible_script.sh
    │  │  ├─ configure.tf # Use Ansible to configure the machine, with Terraform to detect configuration changes
    │  │  ├─ outputs.tf # DynDNS domain to avoid variable declaration repeatition
    │  │  ├─ variables.tf # Inputs variable (DNS token mostly)
    ├─ ansible/ # Shared Ansible resources
    │  ├─ roles/ # Declaration of shared Ansible roles
    │  ├─ ansible.cfg
    │  ├─ requirements.yml
    ├─ services/ # Find all the services here, as Terraform module to deploy multiple of them if necessary
    │  ├─ init.tf
    │  ├─ machines.tf # Initialize machine's related providers (Docker providers), and machine related services like reverse-proxies
    │  ├─ main.tf # Call the services's modules to deploy them on a machine
    │  ├─ dns_domains.tf # Data sources of DNS zones to be used
    │  ├─ variables.tf # Variables needed to deploy services
    │  ├─ gatus/
    │  │  ├─ variables.tf # Module's input variables (mostly for DNS config)
    │  │  ├─ app.tf # Terraform code (Docker image and container). Use provider inheritance to deploy on the correct machine.
    │  │  ├─ src/ # Source files to build the Docker image
    │  │  │  ├─ Dockerfile
    │  │  │  ├─ build.sh # Docker build commands
    │  │  │  ├─ config.yaml # Actual config
    │  ├─ owncloud/
    │  │  ├─ app.tf # Some apps do not need configuration
    │  │  ├─ redis.tf # One service can be comprised of multiple Docker containers
    │  │  ├─ variables.tf
