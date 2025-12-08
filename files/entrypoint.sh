#!/usr/bin/env bash
set -e

NUMBER=$(( $RANDOM % 10 ))

# dangerous and vivid colors:
COLORS=(ff5f00 00ff00 ffcc00 bf00ff 00ffff ff00ff 39ff14 ffff00 8a2be2 ff8c00)

# softer pastel colors:
COLORS_SSL=(e6e6fa f5fffa b0e0e6 ffd8e4 ffdab9 c1e1c1 dcd0ff e7f7ce ccccff caf7c9)

RAND_COLOR=${COLORS[$NUMBER]}
RAND_COLOR_SSL=${COLORS_SSL[$NUMBER]}

F5DEMO_NODENAME=${F5DEMO_NODENAME-$HOSTNAME}
F5DEMO_COLOR=${F5DEMO_COLOR-$RAND_COLOR}
F5DEMO_COLOR_SSL=${F5DEMO_COLOR_SSL-$RAND_COLOR_SSL}
F5DEMO_LISTEN_ADDR=${F5DEMO_LISTEN_ADDR-0.0.0.0}
# defaults to same as F5DEMO_LISTEN_ADDR
F5DEMO_LISTEN_ADDR_SSL=${F5DEMO_LISTEN_ADDR-0.0.0.0}

export F5DEMO_NODENAME
export F5DEMO_COLOR
export F5DEMO_COLOR_SSL
export F5DEMO_LISTEN_ADDR
export F5DEMO_LISTEN_ADDR_SSL

envsubst '$F5DEMO_NODENAME $F5DEMO_COLOR $F5DEMO_COLOR_SSL $F5DEMO_LISTEN_ADDR $F5DEMO_LISTEN_ADDR_SSL' < /etc/nginx/conf.d/f5demo.nginx.conf.template > /etc/nginx/conf.d/f5demo.nginx.conf

echo "F5DEMO_NODENAME: $F5DEMO_NODENAME"
echo "F5DEMO_COLOR: $F5DEMO_COLOR"
echo "F5DEMO_COLOR_SSL: $F5DEMO_COLOR_SSL"
echo "F5DEMO_LISTEN_ADDR: $F5DEMO_LISTEN_ADDR"
echo "F5DEMO_LISTEN_ADDR_SSL: $F5DEMO_LISTEN_ADDR_SSL"


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
