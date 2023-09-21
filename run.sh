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

packages=("ansible" "ansible-playbook" "ansible-galaxy" "vagrant" "curl")
not_installed=false
for pkg in ${packages[@]}; do
    if [[ ! $( which ${pkg} ) ]]; then
        echo "${pkg} is not installed"
        not_installed=true
    fi
done
if [[ $not_installed == true ]]; then
    exit 1
fi

ansible-galaxy install -r requirements.yml

# Run vagrant
vagrant halt
vagrant up

# Check if app is accessible, else rerun provisioning
URL="http://localhost:$LOCAL_PORT"
echo "trying to connect to the app..."
status_code=$(curl -f --connect-timeout 5 --max-time 5 --retry 5 --retry-delay 0 --retry-max-time 30 --retry-connrefused --write-out "%{http_code}" --silent --output /dev/null "$URL")
if [[ $status_code -ne "200" && $( vagrant status | grep "running") ]]; then
    echo "app is not accessible, re-running provision"
    vagrant provision
fi