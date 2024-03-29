IMAGE_REPOSITORY  ?= 797740695898.dkr.ecr.us-east-1.amazonaws.com/observability-api
CURRENT_DIR = $(shell pwd)
ARCH= $(shell uname)
VAULT-ENV_URL=https://github.com/banzaicloud/bank-vaults/releases/download/1.15.1/vault-env-${ARCH}-amd64.tar.gz
GIT_LAST_TAG=$(shell git tag --sort=committerdate|tail -n 1)
GIT_TAG         ?=$(or ${CI_COMMIT_TAG},$(or ${GIT_LAST_TAG}, $(shell git rev-parse --short HEAD) ) )
IMAGE_TAG         ?= ${GIT_TAG}
TARGET_DIR=/usr/local/bin
# SHELL := /bin/bash 
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'	

install: ## Installs binaries to ${TARGET_DIR}
	@{ \
	echo "installing on:${TARGET_DIR}..." ;\
	curl ${VAULT-ENV_URL} --progress-bar -Lo vault-env.tar.gz ;\
	tar -xzvf vault-env.tar.gz vault-env;\
	sudo cp ./kvault-env ${TARGET_DIR}/ && sudo cp ./vault-env ${TARGET_DIR}/ ;\
	echo "ok!" ;\
	}
uninstall: ## Removes binaries from ${TARGET_DIR}
	@{ \
	set -e ;\
	sudo rm ${TARGET_DIR}/kvault-env && sudo rm ${TARGET_DIR}/vault-env ;\
	echo "kvault-env removed from:${TARGET_DIR}\nok!" ;\
	}
  

.PHONY: vault-up
vault-up: ## Spin up a vault development server use it with  export VAULT_ADDR='http://127.0.0.1:8200'
	@docker run \
	--rm --detach --name vault -p 8200:8200 \
	-e 'VAULT_DEV_ROOT_TOKEN_ID=devtoken' \
	--cap-add=IPC_LOCK vault ;\
	vault login devtoken
	
.PHONY: vault-secret	
vault-secret: ## Create a new version of secrets
	vault kv put /secret/testapp dbname=pato password=most_secure_secret last_updated="$$(date)"
	vault kv get /secret/testapp

.PHONY: vault-down 
vault-down: ## Removes docker vault container
	docker rm -fv vault

.PHONY: clean ## Cleans up local environment
clean:
	docker rm -fv vault
	docker-compose down

.PHONY: printvars 
printvars: ## Print Variables for building and versioning
	$(foreach V, $(sort $(.VARIABLES)), \
	$(if $(filter-out environment% default automatic, $(origin $V)),$(warning $V=$($V) ($(value $V)))) \
	)

.PHONY: test-docker 
test-docker: ## Spin up a docker-compose with 3 containers (see README.md)
	kvault-env docker-compose up

.PHONY: test-printvars 
test-printvars: ## Runs a simple printvars test retreiving secrets
	kvault-env printenv|grep VAULT
.PHONY: help
