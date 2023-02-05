#!/bin/bash

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

# domains=(example.org www.example.org)
export POKUS_DOMAINS="rstudio.pokus.io pokus.io"
domains=(${POKUS_DOMAINS})
# rsa_key_size=4096
export POKUS_TLS_CERTS_KEYS_RSA_SIZE=4096
rsa_key_size=${POKUS_TLS_CERTS_KEYS_RSA_SIZE}

# export R_STUDIO_NGINX_VOLUME_DIR="$(pwd)/.run/.nginx"
export R_STUDIO_CERTBOT_VOLUMES_HOME="$(pwd)/.run/.certbot/data/certbot"
# ./rstudio/containers/.run/.certbot/data/certbot/conf
# ./rstudio/containers/.run/.certbot/data/certbot/www


# data_path="./data/certbot"
data_path="${R_STUDIO_CERTBOT_VOLUMES_HOME}"

# email="" # Adding a valid address is strongly recommended
export POKUS_TLS_CERTS_EMAIL="jean.baptiste.lasselle@gmail.com"

email="${POKUS_TLS_CERTS_EMAIL}" # Adding a valid address is strongly recommended

# export POKUS_CERTBOT_STAGING_MODE=0
export POKUS_CERTBOT_STAGING_MODE=1 # Set to 1 if you're testing your setup to avoid hitting request limits

staging=${POKUS_CERTBOT_STAGING_MODE} # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for [$domains]. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi


if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi


# --- # --- #
# 
# Now for the tricky part. We need nginx to perform the Let’s Encrypt validation But nginx won’t start if the certificates are missing.
# 
# So what do we do? Create a dummy certificate, start nginx, delete the dummy and request the real certificates.
# 
# 
# --- # --- #
# 
echo "### Creating dummy certificates for [$domains] ..."

for domain in "${domains[@]}"; do
  cert_home_path="/etc/letsencrypt/live/$domain"
  mkdir -p "$data_path/conf/live/$domain"
  docker-compose run --rm --entrypoint "\
    openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
      -keyout '$cert_home_path/privkey.pem' \
      -out '$cert_home_path/fullchain.pem' \
      -subj '/CN=localhost'" certbot
  echo
done


echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificates for $domains ..."
# docker-compose run --rm --entrypoint "\
#   cert_home_path="/etc/letsencrypt/live/$domain"
#   rm -Rf /etc/letsencrypt/live/$domains && \
#   rm -Rf /etc/letsencrypt/archive/$domains && \
#   rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
# echo

for domain in "${domains[@]}"; do
  cert_home_path_live="/etc/letsencrypt/live/$domain"
  cert_home_path_archive="/etc/letsencrypt/archive/$domain"
  cert_home_path_renewal="/etc/letsencrypt/renewal/$domain"
  # mkdir -p "$data_path/conf/live/$domain"
  docker-compose run --rm --entrypoint "\
      rm -fR $cert_home_path_live \
      rm -fR $cert_home_path_archive \
      rm -fR $cert_home_path_renewal " certbot
  echo
done

echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

 


# --- # --- 
# ---
# 
#  [certonly] means that we only want to generate but not install the certificate (we will do this manually later)
#  
#  # -- REMOVE THIS OPTION FOR DEPLOYMENTS WITH ACTUAL DNS REGISTERED IN PUBLIC INTERNET 
#  [--manual] instructs Certbot to start an interactive dialogue where we can input all required data
#  [--preferred-challenges] dns changes the challenge to use. By default, Certbot uses the HTTP-01 challenge, which we can’t use as I explained.
# 
# --- 
# --- # --- 
# 
docker-compose run --rm --entrypoint "\
  echo && \
  echo '[cat ~/.config/letsencrypt/cli.ini] : ' && \
  echo && \
  ls -alh ~/.config/ && \
  ls -alh ~/.config/letsencrypt/ && \
  ls -alh ~/.config/letsencrypt/*.ini && \
  ls -alh ~/.config/letsencrypt/cli.ini && \
  cat ~/.config/letsencrypt/cli.ini && \
  echo && \
  certbot certonly \
    --manual \
    --preferred-challenges dns \
    --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload
echo "### Stop all services, the stck is ready to staryt ont he user 's command"
docker-compose down