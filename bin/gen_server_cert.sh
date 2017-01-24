#!/bin/sh

set -e
trap 'echo "ERROR $0" 1>&2' 3

# generate CA
if [ ! -e $CERT_DIR/ca.pem ]; then
  cfssl gencert -initca $CFSSL_CONF/ca-csr.json | cfssljson -bare $CERT_DIR/ca -
fi

# generate server certificate and private key
hosts=`jq -r -c '.hosts | @csv' $CFSSL_CONF/server.json | sed -e 's/"//g'`
cfssl gencert \
  -ca=$CERT_DIR/ca.pem \
  -ca-key=$CERT_DIR/ca-key.pem \
  -config=$CFSSL_CONF/ca-config.json \
  -profile=server \
  -hostname="$hosts" \
  $CFSSL_CONF/server.json - \
  | cfssljson -bare $CERT_DIR/server

echo "SUCCESS $0"
