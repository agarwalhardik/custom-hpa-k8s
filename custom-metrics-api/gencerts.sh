#!/usr/bin/env bash

# Detect if we are on mac or should use GNU base64 options
case `uname` in
        Darwin)
            b64_opts='-b=0'
            ;; 
        *)
            b64_opts='--wrap=0'
esac

go get -v -u github.com/cloudflare/cfssl/cmd/...
sudo apt install golang-cfssl


PURPOSE="metrics"
user=$(whoami)
SSL_SUBJ="/C=US/ST=NY/L=NYC/O=UJET/OU=UJET/CN=metrics-ca.dev.gcp.ujet.xyz/emailAddress=sre@ujet.cx"

mkdir -p /home/$user/${PURPOSE}-certs
openssl req -x509 -sha256 -new -nodes -days 3650 -newkey rsa:2048 -keyout /home/$user/${PURPOSE}-certs/${PURPOSE}-ca.key -out /home/$user/${PURPOSE}-certs/${PURPOSE}-ca.crt -subj ${SSL_SUBJ}
echo '{"signing":{"default":{"expiry":"87600h","usages":["signing","key encipherment","'${PURPOSE}'"]}}}' > "/home/$user/${PURPOSE}-certs/${PURPOSE}-ca-config.json"

export SERVICE_NAME=custom-metrics-apiserver
export ALT_NAMES='"custom-metrics-apiserver.monitoring","custom-metrics-apiserver.monitoring.svc"'
echo '{"CN":"'${SERVICE_NAME}'","hosts":['${ALT_NAMES}'],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=/home/$user/${PURPOSE}-certs/metrics-ca.crt -ca-key=/home/$user/${PURPOSE}-certs/metrics-ca.key -config=/home/$user/${PURPOSE}-certs/metrics-ca-config.json - | cfssljson -bare /home/$user/${PURPOSE}-certs/apiserver

cat <<-EOF > cm-adapter-serving-certs.yaml
apiVersion: v1
kind: Secret
metadata:
  name: cm-adapter-serving-certs
  namespace: monitoring
data:
  serving.crt: $(cat /home/$user/${PURPOSE}-certs/apiserver.pem | base64 ${b64_opts})
  serving.key: $(cat /home/$user/${PURPOSE}-certs/apiserver-key.pem | base64 ${b64_opts})
EOF

kubectl apply -f ./cm-adapter-serving-certs.yaml

rm -rf ./cm-adapter-serving-certs.yaml