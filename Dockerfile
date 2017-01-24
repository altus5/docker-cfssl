FROM alpine:3.4

ENV DOWNLOAD_URL=https://pkg.cfssl.org/R1.2

ENV CFSSL_BIN=/opt/cfssl/bin
ENV CFSSL_CONF=/opt/cfssl/conf
ENV CERT_DIR=/etc/cfssl
ENV PATH=$PATH:$CFSSL_BIN

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
