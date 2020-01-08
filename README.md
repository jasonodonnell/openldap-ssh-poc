# OpenLDAP SSH Docker Example

This example sets up an OpenLDAP and SSH containers to test authenticating 
SSH connections using LDAP and PAM.

## Setup

```bash
make
```

## Test

Using the password `password`:

```bash
ssh -l hashicorp 0.0.0.0 -p 2022
```

## Cleanup

```bash
make clean
```
