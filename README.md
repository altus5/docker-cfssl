自己署名認証局(CA)での証明書作成
================================

自己署名認証局(CA)で証明書を作成するコンテナで、証明書作成用のコマンドを内包した、非常駐のDockerコンテナである。  
このコンテナでは、 CFSSL (CloudFlare's PKI/TLS toolkit) を使って、
証明書を作成している。  
CFSSLでは、jsonファイルと、コマンドパラメータの組み合わせで、作成するので、
openssl を使った対話式の手順よりも、わかりやすく、簡単に作成することができる。  

以下は、coreos での自己署名証明書の作成方法である。  
<https://coreos.com/os/docs/latest/generate-self-signed-certificates.html>  
このDockerイメージは、ここに記載されてある、ほぼ、そのままを、コマンドにしてある。

また、自己署名のCAで作成した証明書は、ブラウザでアクセスしたときに、警告が出るが、この警告が出ないようにするには、
CAそのものを認証するために、ブラウザに独自CAの証明書をインストールする必要がある。  
この証明書の作成手順も、コマンド例を記述してある。

## ボリューム

### 証明書が出力されるディレクトリ
/etc/cfssl に証明書が作成されるので、ホスト側のディレクトリで、マウントする。

### 認証属性の設定ファイルを配置するディレクトリ
認証属性は、jsonファイルで作成し、/opt/cfssl/conf に配置する。  
これも、事前に用意した設定ファイルのディレクトリをマウントする。  

## 認証属性のjsonファイル

/opt/cfssl/confに配置するjsonファイルについて説明する。  
はじめに、[coreosでの説明](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html) を見てもらって、そのあと、サンプル（./example/cfssl）のjsonファイルを見ると、わかるんじゃないかとも思う。  
なお、詳細は [cfsslのgithub](https://github.com/cloudflare/cfssl) にある。  

* ca-config.json  
証明書作成に共通した設定で、主に、証明書の有効期限を設定する。  
サンプルでは、5年を有効期限となっている。  
例えば、サーバー証明書だけを作成する場合でも、 client と peer の設定がされていても問題ない。  
* ca-csr.json  
地域や、企業名など、 CA の属性を設定する。  
* server.json  
サーバー証明書の属性を設定する。
サンプルにある CN と hosts を実際のホスト名に修正する。  
* peer/member1.json  
ピア証明書の認証属性で、対向システムとして、必要な証明書を、1つずつ作成する。  
* client/client1.json  
クライアント証明書の認証属性で、必要なクライアント毎に、1つずつ作成する。  

## 証明書の作成コマンド
証明書を作成するときの dokcer のコマンドを例示する。

**サーバー証明書**  
```
docker run --rm -it \
  -v $(pwd)/certs:/etc/cfssl \
  -v $(pwd)/conf:/opt/cfssl/conf \
  altus5/cfssl:0.5.2 \
  gen_server_cert.sh
```

**ピア証明書**  
```
docker run --rm -it \
  -v $(pwd)/certs:/etc/cfssl \
  -v $(pwd)/conf:/opt/cfssl/conf \
  altus5/cfssl:0.5.2 \
  gen_peer_cert.sh
```

**クライアント証明書**  
```
docker run --rm -it \
  -v $(pwd)/certs:/etc/cfssl 
  -v $(pwd)/example/cfssl:/opt/cfssl/conf \
  altus5/cfssl:0.5.2 \
  gen_client_cert.sh
```

**ブラウザにインストールする独自CAの証明書を作成**
```
docker run --rm -it \
  -v $(pwd)/certs:/etc/cfssl \
  -v $(pwd)/conf:/opt/cfssl/conf \
  altus5/cfssl:0.5.2 \
  openssl x509 -in /etc/cfssl/ca.pem -outform DER -out /etc/cfssl/ca.der
```

**サンプルの設定ファイルを取り出す**
カレントディレクトリにサンプルの設定ファイルを取り出す。  
以下のコマンドでは、 ./cfssl にコピーされるので、このサンプルを元に、
修正変更するのが、手っ取り早い。
```
docker run --rm -it \
  -v $(pwd):/srv/hoge \
  altus5/cfssl:0.5.2 \
  cp -r /opt/cfssl/conf /srv/hoge/cfssl
```

## Nginx の適用例

オフィシャルのNginxのコンテナに設定すると、次のようになる。

**設定ファイル**  
CFSSLで作成した証明書を参照するように設定。
```
server {
  listen 80;
  listen 443 ssl;
  server_name _;

  root /var/www

  ssl_certificate     /etc/cfssl/server.pem;
  ssl_certificate_key /etc/cfssl/server-key.pem;
}
```

**nginxコンテナの起動**  
```
docker run --rm -it \
  -v $(pwd)/certs:/etc/cfssl \
  -v $(pwd)/example/nginx/conf.d:/etc/nginx/conf.d \
  -v $(pwd)/example/nginx/www:/var/www \
  -p 80:80 \
  -p 443:443 \
  nginx:1.10.2-alpine
```

自己署名なので、警告は出るが、ホスト名を altus5.local とした場合、 https://altus5.local/ でHello World が表示される。  
警告が出ないようにするには、ブラウザに独自CAの証明書をインストールするとよい。  


