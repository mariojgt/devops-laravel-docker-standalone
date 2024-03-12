.PHONY: start stop build

COMPOSE=sudo docker-compose
DOCKER=sudo docker

# /env
CODE_PATH:= $(shell grep -E '^CODE_PATH' .env | cut -d '=' -f 2)
CONTAINER_PREFIX:= $(shell grep -E '^CONTAINER_PREFIX' .env | cut -d '=' -f 2)

# /*
# |--------------------------------------------------------------------------
# | Docker Network commands
# |--------------------------------------------------------------------------
# */
network:
	$(DOCKER) network create traefik-net
network-list:
	$(DOCKER) network ls

# /*
# |--------------------------------------------------------------------------
# | Docker Container start and stop commands
# |--------------------------------------------------------------------------
# */
start:
	$(COMPOSE) up -d

start-utility:
	$(COMPOSE) -f docker-web-utility.yml up -d

start-nodeapp01:
	$(COMPOSE) -f docker-node01.yml up

stop:
	$(COMPOSE) -f docker-compose.yml down

stop-utility:
	$(COMPOSE) -f docker-web-utility.yml down

stop-nodeapp01:
	$(COMPOSE) -f docker-node01.yml down

# /*
# |--------------------------------------------------------------------------
# | Docker Build
# |--------------------------------------------------------------------------
# */
build:
	$(COMPOSE) build
	$(COMPOSE) -f docker-web-utility.yml build

destroy:
	@$(COMPOSE) rm -v -s -f

# /*
# |--------------------------------------------------------------------------
# | Docker Cache clear
# |--------------------------------------------------------------------------
# */
prune:
	@$(DOCKER) system prune -a


# /*
# |--------------------------------------------------------------------------
# | Utility commands
# |--------------------------------------------------------------------------
# */
list:
	$(COMPOSE) ps -a

# run composer in contianer of name laravel-app and give the permission to laravel bootstrap and storage folder
composer:
	$(COMPOSE) exec app composer install
	$(COMPOSE) exec app chmod -R 777 storage bootstrap/cache

bash-php:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-app /bin/bash
bash-nginx:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-nginx /bin/bash
bash-redis:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-redis /bin/bash
bash-nodeapp01:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-nodeapp01 /bin/bash

# /*
# |--------------------------------------------------------------------------
# | Install Command
# |--------------------------------------------------------------------------
# */
install: network start start-utility
