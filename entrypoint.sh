#!/usr/bin/env bash
set -e

NUMBER=$(( $RANDOM % 6 ))

COLORS=(f59744 c465ff ce5004 f3dd6d 8568c9 ff4caf)

# soft neutral, light blue-gray, pale neutral, aqua pastel, light blue, light green
COLORS_SSL=(dccbc7 d0d7db f4f4f4 88ccc5 92c1e9 addc91)

RAND_COLOR=${COLORS[$NUMBER]}
RAND_COLOR_SSL=${COLORS_SSL[$NUMBER]}

F5DEMO_NODENAME=${F5DEMO_NODENAME-$HOSTNAME}
F5DEMO_COLOR=${F5DEMO_COLOR-$RAND_COLOR}
F5DEMO_COLOR_SSL=${F5DEMO_COLOR_SSL-$RAND_COLOR_SSL}
export F5DEMO_NODENAME
export F5DEMO_COLOR
export F5DEMO_COLOR_SSL

envsubst '$F5DEMO_NODENAME $F5DEMO_COLOR $F5DEMO_COLOR_SSL' < /etc/nginx/conf.d/f5demo.nginx.conf.template > /etc/nginx/conf.d/f5demo.nginx.conf

echo "F5DEMO_NODENAME: $F5DEMO_NODENAME"
echo "F5DEMO_COLOR: $F5DEMO_COLOR"
echo "F5DEMO_COLOR_SSL: $F5DEMO_COLOR_SSL"


  if [ ! -f /etc/nginx/ssl/dhparam.pem ]
  then
    echo "/etc/nginx/ssl/dhparam.pem not found, generating..."
    openssl dhparam -dsaparam -out /etc/nginx/ssl/dhparam.pem 2048 > /dev/null 2>&1
  fi

  if [ ! -f /etc/nginx/ssl/cert.pem ] && [ ! -f /etc/nginx/ssl/key.pem ]
  then
    echo "/etc/nginx/ssl/cert.pem+key.pem not found, generating self-signed cert+key"
    echo -e "[req]\ndistinguished_name=dn\n[dn]\n[ext]\n"\
             "basicConstraints=critical,CA:FALSE\n"\
             "keyUsage=critical,digitalSignature,keyEncipherment\n"\
             "subjectAltName=DNS:example.com,DNS:www.example.com\n"\
             "extendedKeyUsage=critical,serverAuth,clientAuth\n" > /tmp/openssl.conf
    # rsa
    openssl req -x509 -newkey rsa:2048 -nodes -sha256 -batch \
            -days 1825 -config /tmp/openssl.conf -extensions ext \
            -keyout /etc/nginx/ssl/key.pem -out /etc/nginx/ssl/cert.pem \
            -subj "/C=AQ/O=Example Corp./CN=www.example.com" > /dev/null 2>&1
    # ecdsa
    if [ ! -f /etc/nginx/ssl/eccert.pem ] && [ ! -f /etc/nginx/ssl/eckey.pem ]
    then
      openssl ecparam -name prime256v1 > /tmp/prime256v1.ecparam
      openssl req -x509 -newkey ec:/tmp/prime256v1.ecparam -nodes -sha256 -batch \
              -days 1825 -config /tmp/openssl.conf -extensions ext \
              -keyout /etc/nginx/ssl/eckey.pem -out /etc/nginx/ssl/eccert.pem \
              -subj "/C=AQ/O=Example Corp./CN=www.example.com" > /dev/null 2>&1
    fi
    rm -f /tmp/openssl.conf /tmp/prime256v1.ecparam
  fi

  if [ ! -f /etc/nginx/ssl/chain.pem ]
  then
    echo "/etc/nginx/ssl/chain.pem not found, copying from /etc/nginx/ssl/cert.pem and /etc/nginx/ssl/eccert.pem"
    cat /etc/nginx/ssl/cert.pem /etc/nginx/ssl/eccert.pem > /etc/nginx/ssl/chain.pem
  fi



exec "$@"