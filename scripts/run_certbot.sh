echo "Running certbot for domains $DOMAINS"

upload_certificate() {
  local d=${CERT_DOMAINS//,*/} # read first domain

  echo "Certificate is uploading for $CERT_DOMAINS! AWS $CERT_ARN"

  if [ -z $AWS_ACCESS_KEY_ID ]
  then
    if [ -z $CERT_ARN ]
    then
      aws acm import-certificate --certificate file:///etc/letsencrypt/live/$d/cert.pem \
          --certificate-chain file:///etc/letsencrypt/live/$d/chain.pem \
          --private-key file:///etc/letsencrypt/live/$d/privkey.pem
    else
      aws acm import-certificate --certificate file:///etc/letsencrypt/live/$d/cert.pem \
          --certificate-chain file:///etc/letsencrypt/live/$d/chain.pem \
          --private-key file:///etc/letsencrypt/live/$d/privkey.pem \
          --certificate-arn $CERT_ARN
    fi
  fi
}

get_certificate() {
  # Gets the certificate for the domain(s) CERT_DOMAINS (a comma separated list)
  # The certificate will be named after the first domain in the list
  # To work, the following variables must be set:
  # - CERT_DOMAINS : comma separated list of domains
  # - EMAIL
  # - CONCAT
  # - LOG
  # - args

  local d=${CERT_DOMAINS//,*/} # read first domain
  echo "Getting certificate for $CERT_DOMAINS"
  certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /secrets/cloudflare.ini \
  --dns-cloudflare-propagation-seconds 60 \
  --agree-tos -n \
  --server https://acme-v02.api.letsencrypt.org/directory \
  --email $EMAIL -d $CERT_DOMAINS $args
  ec=$?
  echo "certbot exit code $ec"
  if [ $ec -eq 0 ]
  then
    if $CONCAT
    then
      # concat the full chain with the private key (e.g. for haproxy)
      cat /etc/letsencrypt/live/$d/fullchain.pem /etc/letsencrypt/live/$d/privkey.pem > /certs/$d.pem
    else
      # keep full chain and private key in separate files (e.g. for nginx and apache)
      cp /etc/letsencrypt/live/$d/fullchain.pem /certs/$d.pem
      cp /etc/letsencrypt/live/$d/privkey.pem /certs/$d.key
    fi
    echo "Certificate obtained for $CERT_DOMAINS! Your new certificate - named $d - is in /certs"

    if $LOG
    then
      echo "PRIVATE KEY:"
      cat /etc/letsencrypt/live/$d/privkey.pem
      echo "CERT:"
      cat /etc/letsencrypt/live/$d/cert.pem
      echo "CHAIN:"
      cat /etc/letsencrypt/live/$d/chain.pem
    fi

    upload_certificate
  else
    echo "Cerbot failed for $CERT_DOMAINS. Check the logs for details."
  fi
}

get_value_of()
{
  variable_name=$1
  variable_value=""
  if set | grep -q "^$variable_name="; then
    eval variable_value="\$$variable_name"
  fi
  echo "$variable_value"
}

args=""
if $DEBUG
then
  args=$args" --debug"
fi

if $SEPARATE
then
  ITER=0
  for d in $DOMAINS
  do
    CERT_DOMAINS=$d
    CERT_ARN=$(get_value_of "CERT_ARN_$ITER")
    get_certificate
    ITER=$(expr $ITER + 1)
  done
else
  CERT_DOMAINS=${DOMAINS// /,}
  CERT_ARN=${CERT_ARN_0}
  get_certificate
fi
