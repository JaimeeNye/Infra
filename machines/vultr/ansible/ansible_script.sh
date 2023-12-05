#!/bin/sh

export ANSIBLE_CONFIG="../../../ansible/ansible.cfg"

ansible-galaxy install -r ../../../ansible/requirements.yml

while ! ansible-playbook -v -i inventory.yml playbook.yml; do
    echo "Failed to configure server, retrying in 20 seconds"
    sleep 20
done

