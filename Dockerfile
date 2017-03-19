FROM alpine:3.4

ENV DOWNLOAD_URL=https://pkg.cfssl.org/R1.2

ENV CFSSL_BIN=/opt/cfssl/bin
ENV CFSSL_CONF=/opt/cfssl/conf
ENV CERT_DIR=/etc/cfssl
ENV PATH=$PATH:$CFSSL_BIN

ENV CA_CONFIG_CONF=$CFSSL_CONF/ca-config.json
ENV CA_CSR_CONF=$CFSSL_CONF/ca-csr.json
ENV CA_CERT_PREFIX=$CERT_DIR/ca
ENV SERVER_CONF=$CFSSL_CONF/server.json
ENV SERVER_CERT_PREFIX=$CERT_DIR/server
ENV CLIENT_CONF_GLOB=$CFSSL_CONF/client
ENV CLIENT_CERT_DIR=$CERT_DIR
ENV PEER_CONF_GLOB=$CFSSL_CONF/peer
ENV PEER_CERT_DIR=$CERT_DIR

RUN \
  apk add --no-cache openssl jq && \
  apk add --no-cache --virtual .builddeps curl && \
  mkdir -p $CFSSL_BIN && \
  curl -s -L -o $CFSSL_BIN/cfssl $DOWNLOAD_URL/cfssl_linux-amd64 && \
  curl -s -L -o $CFSSL_BIN/cfssljson $DOWNLOAD_URL/cfssljson_linux-amd64 && \
  apk del .builddeps

COPY bin/ $CFSSL_BIN/
COPY conf/ $CFSSL_CONF/

RUN \
  chmod +x $CFSSL_BIN/*

