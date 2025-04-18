#!/usr/bin/env bash
set -euo pipefail

usage="Usage: makecert <alias> (Default is mycert) <validity in days> (Default is 365 days)"
if [[ $# -gt 0 && ("$1" == "-h" || "$1" == "--help") ]]; then
  echo $usage
  exit 1
fi

alias=${1:-mycert}
validity=${2:-365}
openssl genpkey -des3 -algorithm RSA -pass pass:SomePassword -out server.pass.key -pkeyopt rsa_keygen_bits:2048
openssl rsa -passin pass:SomePassword -in server.pass.key -out server.key
openssl req -new -key server.key -out server.csr
openssl x509 -req -sha256 -days $validity -in server.csr -signkey server.key -out server.crt
rm server.pass.key server.csr

# Convert server.crt and server.key to server.pfx
openssl pkcs12 -export -out server.pfx -inkey server.key -in server.crt -passout pass:changeit -name $alias

# Convert server.pfx to server.jks and give it an alias of "server"
keytool -importkeystore -srckeystore server.pfx -srcstoretype pkcs12 -destkeystore server.jks -deststoretype JKS -srcstorepass changeit -deststorepass changeit -alias $alias -noprompt
