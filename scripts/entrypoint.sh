#!/bin/sh
set -e

echo "dns_cloudflare_api_token = ${CLOUDFLARE_TOKEN}" > /secrets/cloudflare.ini
chmod 0600 /secrets/cloudflare.ini 

exec "$@"
