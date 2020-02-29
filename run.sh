#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ORG='HashiCorp'
DOMAIN='hashicorp.com'
ADMIN_USER='cn=admin,dc=hashicorp,dc=com'
ADMIN_PASSWORD='admin'
USERNAME='cn=tamara,ou=users,dc=hashicorp,dc=com'
USER_PASSWORD='password'
LDAP_IMAGE='osixia/openldap:1.3.0'

${DIR?}/cleanup.sh

export VAULT_DEV_ROOT_TOKEN_ID="root"
export VAULT_ADDR="http://0.0.0.0:8200"

docker network create --driver bridge ldap

docker run \
  --name=ldap \
  --hostname=ldap \
  --network=ldap \
  -p 389:389 \
  -p 636:636 \
  -e LDAP_ORGANISATION="${ORG?}" \
  -e LDAP_DOMAIN="${DOMAIN?}" \
  -e LDAP_ADMIN_PASSWORD="${ADMIN_PASSWORD?}" \
  --detach ${LDAP_IMAGE?}

sleep 5

ldapadd -x -w ${ADMIN_PASSWORD?} -D "${ADMIN_USER?}" -f ./configs/ldap-seed.ldif
ldappasswd -s ${USER_PASSWORD?} -w ${ADMIN_PASSWORD?} -D "${ADMIN_USER?}" -x "${USERNAME?}"

docker run \
  --name=vault \
  --hostname=vault \
  --network=ldap \
  -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID="root" \
  -e VAULT_ADDR="http://localhost:8200" \
  -e VAULT_DEV_LISTEN_ADDRESS="0.0.0.0:8200" \
  --privileged \
  --detach vault:1.4.0-beta1

sleep 2

vault login root

vault secrets enable openldap
