#!/bin/bash

# Set environment variables
source .env

command=$1
if [[ -n "$command" && "$command" -eq "destroy" ]]; then
    vagrant destroy
    exit 0
fi

# Check dependencies
if [[ ! $(pip list | grep -F docker) ]]; then
    echo "python-docker not installed"
    exit 1
fi

packages=("ansible" "ansible-playbook" "ansible-galaxy")
for pkg in ${packages[@]}; do
    if [[ ! $( which ${pkg} ) ]]; then
        echo "${pkg} is not installed"
        exit 1
    fi
done
ansible-galaxy install -r requirements.yml

# Run vagrant
if [[ ! $( vagrant status | grep "running") ]]; then
    vagrant up
fi

# Check if app is accessible, else rerun provisioning
URL="http://$NGINX_HOST:$LOCAL_PORT"
status_code=$(curl --write-out "%{http_code}\n" --silent --output /dev/null "$URL")
if [[ $status_code -ne 200 && $( vagrant status | grep "running") ]]; then
    vagrant provision
fi