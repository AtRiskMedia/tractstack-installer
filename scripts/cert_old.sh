#!/bin/bash

certbot --non-interactive --agree-tos --email admin@atriskmedia.com certonly --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/certbot/cloudflare.ini "$@"

# $1:
#  -d example.com -d www.example.com

