#!/bin/sh

set -e
trap 'echo "ERROR $0" 1>&2' 3

# generate CA
if [ ! -e $CERT_DIR/ca.pem ]; then
  cfssl gencert -initca $CFSSL_CONF/ca-csr.json | cfssljson -bare $CERT_DIR/ca -
fi

# generate member certificate and private key
for conf in $(find $CFSSL_CONF/peer -type f)
do
  hosts=`jq -r -c '.hosts | @csv' $conf | sed -e 's/"//g'`
  cn=`jq -r  '.CN' $conf`
  cfssl gencert \
    -ca=$CERT_DIR/ca.pem \
    -ca-key=$CERT_DIR/ca-key.pem \
    -config=$CFSSL_CONF/ca-config.json \
    -profile=peer \
    -hostname="$hosts" \
    $conf - \
    | cfssljson -bare $CERT_DIR/$cn
done

echo "SUCCESS $0"
