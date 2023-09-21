## Build Instructions
The entire stack can be run by executing `run.sh`. There are some default environment variables defined in `.env` which will be used to configure different parameters.

Use `./run.sh destroy` to destroy the VM.

Using default values, the app can be reached at [http://localhost:8000](http://localhost:8000).

Grafana should be available at [http://localhost:3000](http://localhost:3000). A new [dashboard](http://localhost:3000/d/xDLNRKUWz/app-dashboard?orgId=1&refresh=30s&from=now-5m&to=now) is automatically provisioned which can be found under the `General` folder. Default username and password is `admin`.

Prometheus should be available at [http://localhost:9090](http://localhost:9090)

The ansible playbook uses various roles.
- common: This role installs some default packages, creates the required user and groups, updates hostname and timezone.

- security: This role modifies SSH config to make it more secure, installs and configures fail2ban, disables root login, configures a basic firewall using UFW, and sets some default sysctl values.

- docker: This role installs and configures docker.

- k3s: This roles installs and configures k3s and kubectl.

- app: This role deploys the demo app and other services to either docker or k3s based on the configuration.

## Configuration
All roles have default values defined under `<role>/defaults/main.yml`. These values can be overriden from `playbook.yml`. Some values are configured to use environment variables for easy configuration.

### Use SSL
There is an environment variable under `.env` called `APP_USE_SSL` which can be updated to `true`. This will generate a self signed certificate that will be used by the nginx container. There is no HTTP to HTTPS redirect. The app can be directly reached at [https://localhost:8000](https://localhost:8000).

This will only work when `APP_ENV` is set to `docker`.

### Use k3s
If `APP_ENV` under `.env` is set to `k3s`, the app would be deployed to k3s. The `APP_NODEPORT` variable would be used for port-forwarding to the VM and the app would be accessible at `LOCAL_PORT`. Default [http://localhost:8000](http://localhost:8000).

## Dependencies
Virtualbox is used as the provider for Vagrant.

Ansible collections
- [community.general](https://docs.ansible.com/ansible/latest/collections/community/general/index.html)
- [community.docker](https://docs.ansible.com/ansible/latest/collections/community/docker/index.html)
- [ansible.posix](https://docs.ansible.com/ansible/latest/collections/ansible/posix/index.html)

`python-docker` also needs to be installed for `community.docker` to work.
```bash
sudo apt install python3-docker   # Debian based systems
sudo pacman -S python-docker      # Archlinux
sudo dnf install python-docker-py # Redhat
```

### Dev Environment
- Archlinux (Linux 6.4.12-arch1-1)
- Ansible (core 2.15.3)
- Vagrant (2.3.7)
- Virtualbox (7.0.10)