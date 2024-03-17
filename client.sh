#!/bin/sh

if [ ! -d server ]; then
	echo call server.sh first
	exit 1
fi

if [ -z "$1" ]; then
	echo "invoke with './$0 <serial>'"
	exit 1
fi

if [ -d $1 ]; then
	echo folder $1 already exists
	exit 1
fi

mkdir $1

. ./subject.conf

SUBJ="/C=$C/ST=$ST/L=$L/O=$O/CN=$1"

echo +++++ generate client private key
openssl ecparam -name prime256v1 -genkey -noout -out $1/key.pem

echo +++++ generate client private CSR
openssl req -new -sha256 -key $1/key.pem -subj "$SUBJ" -out $1/csr.pem

echo +++++ generate client certificate
openssl x509 -req -in $1/csr.pem -CA server/ca.pem -CAkey server/ca.key -CAcreateserial -out $1/cert.pem -days $EXPIRE -sha256

openssl pkcs12 -export -out $1/$1.pfx -inkey $1/key.pem -in $1/cert.pem -certfile server/ca.pem

cp server/ca.pem $1
cd $1
tar cf ../$1.tar ca.pem cert.pem key.pem
