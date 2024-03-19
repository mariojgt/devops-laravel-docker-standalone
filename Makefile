.PHONY: start stop build

COMPOSE=sudo docker-compose
DOCKER=sudo docker

# /env
CODE_PATH:= $(shell grep -E '^CODE_PATH' .env | cut -d '=' -f 2)
CONTAINER_PREFIX:= $(shell grep -E '^CONTAINER_PREFIX' .env | cut -d '=' -f 2)
HOST_PREFIX:= $(shell grep -E '^HOST_PREFIX' .env | cut -d '=' -f 2)
APP_NAME:= $(shell grep -E '^APP_NAME' .env | cut -d '=' -f 2)
NODE_01_DOMAIN:= $(shell grep -E '^NODE_01_DOMAIN' .env | cut -d '=' -f 2)
NODE_01_PORT_EXPOSE:= $(shell grep -E '^NODE_01_PORT_EXPOSE' .env | cut -d '=' -f 2)
NODE_02_DOMAIN:= $(shell grep -E '^NODE_02_DOMAIN' .env | cut -d '=' -f 2)
NODE_02_PORT_EXPOSE:= $(shell grep -E '^NODE_02_PORT_EXPOSE' .env | cut -d '=' -f 2)

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

start-nodeapp:
	$(COMPOSE) -f docker-node.yml up

start-nodeapp2:
	$(COMPOSE) -f docker-node2.yml up

stop:
	$(COMPOSE) -f docker-compose.yml down

stop-utility:
	$(COMPOSE) -f docker-web-utility.yml down

stop-nodeapp:
	$(COMPOSE) -f docker-node.yml down

stop-nodeapp2:
	$(COMPOSE) -f docker-node2.yml down
# /*
# |--------------------------------------------------------------------------
# | Docker Build
# |--------------------------------------------------------------------------
# */
build:
	$(COMPOSE) build --no-cache
	$(COMPOSE) -f docker-web-utility.yml build
	$(COMPOSE) -f docker-node.yml build

destroy:
	@$(COMPOSE) rm -v -s -f

delete-volumes:
	@$(DOCKER) volume rm $(shell $(DOCKER) volume ls -q)

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


# ANSI escape codes for colors
RED := \033[0;31m
GREEN := \033[0;32m
RESET := \033[0m
BLUE := \033[0;34m
YELLOW := \033[0;33m
PURPLE := \033[0;35m
FIRE := \033[0;91m

links:
	@echo "$(RED)http://${APP_NAME}-${CONTAINER_PREFIX}.${HOST_PREFIX}/ (Laravel)"
	@echo "$(GREEN)http://phpmyadmin-${CONTAINER_PREFIX}.${HOST_PREFIX}/ (PhpMyAdmin)"
	@echo "$(GREEN)http://phpmyadmin-archive-${CONTAINER_PREFIX}.${HOST_PREFIX}/ (PhpMyAdmin-secondaryDB)"
	@echo "$(RESET)http://meilisearch-${CONTAINER_PREFIX}.${HOST_PREFIX}/ (Meilisearch)"
	@echo "$(BLUE)http://localhost:8080/ (Traefik)"
	@echo "$(YELLOW)http://portainer-${CONTAINER_PREFIX}.${HOST_PREFIX}/ (Portainer)"
	@echo "$(PURPLE)http://redis-insight-${CONTAINER_PREFIX}.${HOST_PREFIX}/ (Redis Insight)"
	@echo "$(FIRE)http://${NODE_01_DOMAIN}-${CONTAINER_PREFIX}.${HOST_PREFIX}:${NODE_01_PORT_EXPOSE}/ (Node App 01)"
	@echo "$(FIRE)http://${NODE_02_DOMAIN}-${CONTAINER_PREFIX}.${HOST_PREFIX}:${NODE_02_PORT_EXPOSE}/ (Node App 02)"

# run composer in contianer of name laravel-app and give the permission to laravel bootstrap and storage folder
composer:
	$(COMPOSE) exec php-app composer install
	$(COMPOSE) exec php-app chmod -R 777 ./

bash-php:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-app /bin/bash
bash-nginx:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-nginx /bin/bash
bash-redis:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-redis /bin/bash
bash-nodeapp01:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-nodeapp01 /bin/bash
bash-nodeapp02:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-nodeapp02 /bin/bash
# /*
# |--------------------------------------------------------------------------
# | Install Command
# |--------------------------------------------------------------------------
# */
install: network build start start-utility start-nodeapp composer links

uninstall: stop stop-utility stop-nodeapp destroy prune delete-volumes
