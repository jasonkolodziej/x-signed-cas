#!/bin/sh

createServer()
{
	umask 077
	CA1=$1
	CA2=$2
	SERVER=$3
	mkdir -p ${SERVER}

	echo "Creating openSSL server for = ${SERVER}"
	echo

	echo "Creating ${SERVER}'s private key"
	echo
	# generate server private key
	openssl genrsa -aes256 -out ${SERVER}/private.key.pem 4096

	echo "Creating ${SERVER}'s Cert-Siging Request"
	echo
	# create server CSR
	openssl req -config ${SERVER}-openssl.cnf \
		-key ${SERVER}/private.key.pem \
		-new -sha256 -days 1337 \
		-out ${SERVER}/server.csr.pem

	echo "Signing ${SERVER}'s Cert-Siging Request with ${CA1}"
	echo
	# sign CSR with CA1
	openssl ca -config ${CA1}-openssl.cnf \
		-keyfile ${CA1}/private/ca.key.pem \
		-out ${SERVER}/${SERVER}-${CA1}.cert.pem \
		-infiles ${SERVER}/server.csr.pem

	echo "Signing ${SERVER}'s Cert-Siging Request with ${CA2}"
	echo
	# sign CSR with CA2
	openssl ca -config ${CA2}-openssl.cnf \
		-keyfile ${CA2}/private/ca.key.pem \
		-out ${SERVER}/${SERVER}-${CA2}.cert.pem \
		-infiles ${SERVER}/server.csr.pem
}

rm -rf server-cross-signed
createServer "CA1" "CA2" "server-cross-signed"
