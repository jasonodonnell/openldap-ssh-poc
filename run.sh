#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ORG='HashiCorp'
DOMAIN='hashicorp.com'
ADMIN_USER='cn=admin,dc=hashicorp,dc=com'
ADMIN_PASSWORD='admin'
USERNAME='uid=hashicorp,ou=users,dc=hashicorp,dc=com'
USER_PASSWORD='password'
LDAP_IMAGE='osixia/openldap:1.3.0'
SSHD_IMAGE='sshtest:1.0.0'

${DIR?}/cleanup.sh

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

#ldapdelete -x -w ${ADMIN_PASSWORD?} -D "${ADMIN_USER?}" -x "${USERNAME?}"
ldapadd -x -w ${ADMIN_PASSWORD?} -D "${ADMIN_USER?}" -f ./configs/base.ldif
ldapadd -x -w ${ADMIN_PASSWORD?} -D "${ADMIN_USER?}" -f ./configs/hashicorp.ldif
ldappasswd -s ${USER_PASSWORD?} -w ${ADMIN_PASSWORD?} -D "${ADMIN_USER?}" -x "${USERNAME?}"

docker run \
  --name=sshd \
  --hostname=sshd \
  --network=ldap \
  -p 2022:22 \
  -e SSH_PASSWORD_AUTHENTICATION='true' \
  --detach ${SSHD_IMAGE?}
