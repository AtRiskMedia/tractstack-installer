#!/bin/bash
EMAIL='admin@atriskmedia.com'

# Activate the virtual environment and run Certbot
source /home/t8k/certbot_venv/bin/activate
certbot --non-interactive --agree-tos --email "$EMAIL" certonly --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/certbot/cloudflare.ini "$@"
deactivate

# $1:
#  -d example.com -d www.example.com
