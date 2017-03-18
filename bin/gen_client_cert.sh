#!/bin/sh

set -e
trap 'echo "ERROR $0" 1>&2' 3

# generate CA
if [ ! -e $CA_PEM ]; then
  cfssl gencert -initca $CA_CSR_CONF | cfssljson -bare $CERT_DIR/ca -
fi

# generate member certificate and private key
for conf in $(find $CLIENT_CONF_GLOB -type f)
do
  hosts=`jq -r -c '.hosts | @csv' $conf | sed -e 's/"//g'`
  cn=`jq -r  '.CN' $conf`
  cfssl gencert \
    -ca=$CA_PEM \
    -ca-key=$CA_KEY_PEM \
    -config=$CA_CONFIG_CONF \
    -profile=client \
    -hostname="$hosts" \
    $conf - \
    | cfssljson -bare $CLIENT_CERT_DIR/$cn
done

echo "SUCCESS $0"
