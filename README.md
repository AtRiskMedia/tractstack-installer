# Tract Stack installer scripts

Visit [Tract Stack docs](https://tractstack.org) for more info

## Ansible

If you're installing Tract Stack from scratch and need a server, we've got you covered.

In `/ansible` you'll find playbooks:

`build_server.yml` initializes the server:

- installs some dependencies and helpers: `vnstat`, `htop`, `rsync`, `zip`, `mutt`, `libwww-perl`, `locate`, `dnsutils`, `wget`, `curl`, `lnav`, `snapd`, `pwgen`, `vim`
- set-up [ConfigServer Security and Firewall](https://configserver.com/configserver-security-and-firewall/), [MariaDB](https://mariadb.org/), and [Certbot](https://certbot.eff.org/)

`build_server_t8k.yml` prepares the server for Tract Stack:

- installs [neovim](https://neovim.io/), [git](https://www.git-scm.com/)
- installs [docker](https://www.docker.com/)
- activates [Nginx](https://nginx.org/) / [PHP-fpm](https://www.php.net/manual/en/install.fpm.php), [composer](https://getcomposer.org/), [nodejs](https://nodejs.org/) using playbooks maintained by [Jeff Geerling](https://github.com/geerlingguy)
- installs [yarn](https://yarnpkg.com/) and versioning via [corepack](https://yarnpkg.com/corepack)
- installs [astro](https://github.com/withastro/astro), [tailwindcss](https://tailwindcss.com/docs/installation), [gatsby](https://www.gatsbyjs.com/) _note: the prototype story keep is written in gatsby and is being ported to astro_

### Install ansible roles

Git the needed ansible role repos:

```bash
cd ansible/roles
git clone https://github.com/geerlingguy/ansible-role-composer
git clone https://github.com/geerlingguy/ansible-role-nginx
git clone https://github.com/geerlingguy/ansible-role-nodejs
git clone https://github.com/geerlingguy/ansible-role-php
git clone https://github.com/likg/ansible-role-csf
```

### Configure your server params

_Be sure_ to review `./ansible/templates/*` where you'll set your API keys, SSH keys, MySQL pwd, etc.

- `./ansible/templates/issue`: this is the banner text on SSH login
- `./ansible/templates/.my.cnf`: set your MySQL root password
- `./ansible/templates/public_keys`: add your public SSH keys *note: this assumes you have [passwordless SSH](https://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/) enabled*
- `./ansible/templates/secret-certbot`: add your [Cloudflare API credentials](https://certbot-dns-cloudflare.readthedocs.io/)

### First run

If you are running these playbooks remotely, you'll need to take special action on 'first run' (before your SSH keys are installed).

To temporarily allow root log-in via SSH (before copying your SSH key):

- in `/etc/ssh/sshd_config` temporarily set `PermitRootLogin` = yes
- then restart ssh, `sudo systemctl restart sshd`

Then on first run, use `ansible-playbook -u root -k build_server.yml`

### Subsequent runs

To re-run the playbook, use `ansible-playbook -u root build_server.yml` and `ansible-playbook -u root build_server_t8k.yml`

