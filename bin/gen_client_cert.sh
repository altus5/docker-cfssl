#!/bin/sh

set -e
trap 'echo "ERROR $0" 1>&2' 3

basedir=$(cd $(dirname $0) && pwd)
. $basedir/gen_ca_cert.sh

# generate member certificate and private key
for conf in $(find $CLIENT_CONF_GLOB -type f)
do
  cn=`jq -r  '.CN' $conf`
  cfssl gencert \
    -ca=$CA_PEM \
    -ca-key=$CA_KEY_PEM \
    -config=$CA_CONFIG_CONF \
    -profile=client \
    -hostname="$cn" \
    $conf - \
    | cfssljson -bare $CLIENT_CERT_DIR/$cn
done

echo "SUCCESS $0"
