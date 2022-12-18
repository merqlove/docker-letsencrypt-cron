# docker-letsencrypt-cron
Create and automatically renew website SSL certificates using the letsencrypt free certificate authority, and its client *certbot* via Cloudflare validation.

This image will renew your certificates every 2 months.  

### Also:
 - Stores received certs into `certs` folder
 - Pushing received certs into AWS Cert Manager (Optional).

# Usage

## Setup

In docker-compose.yml, change the environment variables:
- DOMAINS: a space separated list of domains for which you want to generate certificates.
- EMAIL: where you will receive updates from letsencrypt.
- CONCAT: true or false, whether you want to concatenate the certificate's full chain with the private key (required for e.g. haproxy), or keep the two files separate (required for e.g. nginx or apache).
- SEPARATE: true or false, whether you want one certificate per domain or one certificate valid for all domains.
- CLOUDFLARE_TOKEN: Cloudflare token, for DNS based validation.
- CERT_ARN_0,CERT_ARN_1,...: Optional, only if you need AWS. If you have ARN's of your certificates on AWS side. If not certs will be created.
- AWS_SECRET_ACCESS_KEY: Optional, only if you need AWS
- AWS_ACCESS_KEY_ID: Optional, only if you need AWS
- AWS_DEFAULT_REGION: Optional, only if you need AWS


## Running

### Using the automated image

```shell
docker run --name certbot -v `pwd`/certs:/certs --restart always -e "DOMAINS=domain1.com domain2.com" -e "EMAIL=webmaster@domain1.com" -e "SEPARATE=true" -e "CLOUDFLARE_TOKEN=" merqlove/docker-letsencrypt-cron
```

### Building the image

The easiest way to build the image yourself is to use the provided docker-compose file.

```shell
docker-compose up -d
```

The first time you start it up, you may want to run the certificate generation script immediately:

```shell
docker exec certbot ash -c "/scripts/run_certbot.sh"
```

At 3AM, on the 1st of every odd month, a cron job will start the script, renewing your certificates.

## Cloudflare token

- Please create cloudflare token with access to Zones, that you want.
- https://developers.cloudflare.com/fundamentals/api/get-started/create-token/

## AWS Certificate manager

### Access keys

- Create IAM user with full programmatic acces only to Certificate Manager.
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html#getting-started-prereqs-keys


### Naming
#### If you already have ARN which can be used to reimport:  
##### If you have `SEPARATE=true`
  - You must set same amount variables `CERT_ARN_N` as you have domains.
  - For example, you have two domains, you add `CERT_ARN_0`, `CERT_ARN_1`.
##### Otherwise
  - Just set `CERT_ARN_0` with single


# More information

Find out more about letsencrypt: https://letsencrypt.org

Certbot github: https://github.com/certbot/certbot

# Changelog

### 0.1
- Initial release
