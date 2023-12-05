#!/bin/sh

set -e

cd machines
terraform init
terraform plan
cd ..
cd services
terraform init
terraform $@
cd ..
