#!/bin/sh
if [ -d server ]; then
	echo server folder already exists
	exit 1
fi

mkdir server

. ./subject.conf

SUBJ="/C=$C/ST=$ST/L=$L/O=$O/CN=$CN"

echo +++++ generate CA private key
openssl ecparam -name prime256v1 -genkey -noout -out server/ca.key

echo +++++ generate the CA certificate
openssl req -new -x509 -sha256 -key server/ca.key -subj "$SUBJ" -out server/ca.pem

echo +++++ generate server private key
openssl ecparam -name prime256v1 -genkey -noout -out server/key.pem

echo +++++ generate the server CSR
openssl req -new -sha256 -key server/key.pem -subj "$SUBJ" -out server/csr.pem

echo +++++ generate the server certificate
openssl x509 -req -in server/csr.pem -CA server/ca.pem -CAkey server/ca.key -CAcreateserial -out server/cert.pem -days $EXPIRE -sha256

cd server
tar cf ../server.tar ca.pem cert.pem key.pem
