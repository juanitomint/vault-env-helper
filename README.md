# Kubernetes like vault-env-helper

This project installs a vault helper 

With the command kvault-env you can run containers with secrets the same way you do in kubernetes with [Banzai Mutating Webhook](https://banzaicloud.com/docs/bank-vaults/mutating-webhook/)

kvault-env will pick up secrets path from a dot env file

.env 
```bash
VAULT_DBNAME=vault:secret/data/testapp#dbname
VAULT_PASSWORD=vault:secret/data/testapp#password 
VAULT_LAST_UPDATED=vault:secret/data/testapp#last_updated 
```

and inject the secrets to the the command 
```bash
kvault-env printenv|grep VAULT
INFO[0000] spawning process: [printenv]                  app=vault-env
VAULT_PASSWORD=most_secure_secret
VAULT_LAST_UPDATED=Sun 15 May 2022 07:57:35 PM -03
VAULT_DBNAME=pato

```

## INSTALLATION
```bash
make install
```
## Uninstall/Remove
```bash
make uninstall
```

## TEST


spin up a local vault instance using docker
```bash
export VAULT_ADDR='http://127.0.0.1:8200'
make vault-up 
make vault-secret
make test-docker
```
Dcocker compose will spin up a database, adminer and podinfo

you can use podman to check environment variables passed to container

 ![http://localhost:9898/env](https://github.com/juanitomint/vault-env-helper/blob/main/img/podinfo.png?raw=true)

or  access the db using adminer

 ![http://localhost:8080](https://github.com/juanitomint/vault-env-helper/blob/main/img/adminer.png?raw=true)

## HELP
```bash
make
install              Installs binaries to ${TARGET_DIR}
printvars            Print Variables for building and versioning
test-docker          Spin up a docker-compose with 3 containers (see README.md)
test-printvars       Runs a simple printvars test retreiving secrets
uninstall            Removes binaries from ${TARGET_DIR}
vault-down           Removes docker vault container
vault-secret         Create a new version of secrets
vault-up             Spin up a vault development server use it with  export VAULT_ADDR='http://127.0.0.1:8200'
```