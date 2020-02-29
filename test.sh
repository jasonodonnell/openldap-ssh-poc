#!/bin/bash

set -e

vault write openldap/config \
  binddn="cn=admin,dc=hashicorp,dc=com" \
  bindpass="admin" \
  url="ldap://ldap" && sleep 1


vault write openldap/static-role/tamara \
  username='tamara' \
  dn='cn=tamara,ou=users,dc=hashicorp,dc=com' \
  rotation_period="5s" && sleep 1

vault read openldap/static-role/tamara && sleep 1

vault list openldap/static-role && sleep 1

vault read openldap/static-cred/tamara && sleep 1

vault write -f openldap/rotate-role/tamara
