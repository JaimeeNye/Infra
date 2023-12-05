#!/bin/sh

export ANSIBLE_CONFIG="../../../ansible/ansible.cfg"

ansible-galaxy install -r ../../../ansible/requirements.yml

ansible-playbook -v -i inventory.yml playbook.yml

