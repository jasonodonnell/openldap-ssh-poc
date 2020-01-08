#!/bin/bash

docker rm ldap --force
docker rm sshd --force
docker network rm ldap
