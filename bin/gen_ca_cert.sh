#!/bin/sh

set -e
trap 'echo "ERROR $0" 1>&2' 3

export CA_PEM=$CA_CERT_PREFIX.pem
export CA_KEY_PEM=$CA_CERT_PREFIX-key.pem

# generate CA
if [ ! -e $CA_PEM ]; then
  cfssl gencert -initca $CA_CSR_CONF | cfssljson -bare $CA_CERT_PREFIX -
else
  echo "$CA_PEM already exists"
fi

echo "SUCCESS $0"
