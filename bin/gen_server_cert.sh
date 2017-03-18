#!/bin/sh

set -e
trap 'echo "ERROR $0" 1>&2' 3

# generate CA
if [ ! -e $CA_PEM ]; then
  cfssl gencert -initca $CA_CSR_CONF | cfssljson -bare $CERT_DIR/ca -
fi

# generate server certificate and private key
hosts=`jq -r -c '.hosts | @csv' $SERVER_CONF | sed -e 's/"//g'`
cfssl gencert \
  -ca=$CA_PEM \
  -ca-key=$CA_KEY_PEM \
  -config=$CA_CONFIG_CONF \
  -profile=server \
  -hostname="$hosts" \
  $SERVER_CONF - \
  | cfssljson -bare $SERVER_CERT_PREFIX

echo "SUCCESS $0"
