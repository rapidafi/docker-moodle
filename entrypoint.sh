#!/bin/bash
# Requires vars CERT_DOMAIN and CERT_EMAIL

# default servername (directly to enabled)
if [ ! -f /etc/apache2/conf-enabled/servername.conf ]; then
  echo "ServerName $CERT_DOMAIN" > /etc/apache2/conf-enabled/servername.conf
fi

# Certbot
if [ ! -f /certbot-setup.sh ]; then
  # Enable apache for certbot briefly
  source /etc/apache2/envvars
  service apache2 status > /dev/null
  if (( $? )); then
    service apache2 start
  fi

  # make a script that installs certificate via certbot
  # - keep already acquired certificate if exists
  # - enables http->https redirect (enables apache mod rewrite)
  # - nb! uses staging (not validated) certificates
  echo "certbot --non-interactive --agree-tos \
    --staging \
    --keep --redirect --apache \
    --email $CERT_EMAIL \
    --domains $CERT_DOMAIN" > /certbot-setup.sh
  chmod +x /certbot-setup.sh
  # run certbot (this one time; renewal todo...)
  /certbot-setup.sh

  service apache2 stop
fi

read pid cmd state ppid pgrp session tty_nr tpgid rest < /proc/self/stat
trap "kill -TERM -$pgrp; exit" EXIT TERM KILL SIGKILL SIGTERM SIGQUIT

source /etc/apache2/envvars
tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND
