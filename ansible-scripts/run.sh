#!/bin/bash

# . ./unimelb-comp90024-group-58-openrc.sh; ansible-playbook --ask-become-pass apply-instance.yml

# . ./unimelb-comp90024-group-58-openrc.sh; ansible-playbook -i inventory.ini -u ubuntu --key-file=./Group58 -v docker-configuration.yml

. ./unimelb-comp90024-group-58-openrc.sh; ansible-playbook -i inventory.ini -u ubuntu --key-file=./Group58 -v couchdb-cluster-setup.yml