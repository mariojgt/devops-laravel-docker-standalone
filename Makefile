.PHONY: help start stop build

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
NODE_01_APP_NAME:= $(shell grep -E '^NODE_01_APP_NAME' .env | cut -d '=' -f 2)
NODE_02_APP_NAME:= $(shell grep -E '^NODE_02_APP_NAME' .env | cut -d '=' -f 2)

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
	@echo "$(RED)http://${APP_NAME}.${CONTAINER_PREFIX}.${HOST_PREFIX}/ (Laravel Apache)"
	@echo "$(RED)http://${APP_NAME}.${CONTAINER_PREFIX}.2.${HOST_PREFIX}/ (Laravel Nginx)"
	@echo "$(GREEN)http://phpmyadmin.${CONTAINER_PREFIX}.${HOST_PREFIX}/ (PhpMyAdmin)"
	@echo "$(GREEN)http://phpmyadmin-archive.${CONTAINER_PREFIX}.${HOST_PREFIX}/ (PhpMyAdmin-secondaryDB)"
	@echo "$(YELLOW)http://meilisearch.${CONTAINER_PREFIX}.${HOST_PREFIX}/ (Meilisearch)"
	@echo "$(PURPLE)http://localhost:8080/ (Traefik)"
	@echo "$(PURPLE)http://portainer-${CONTAINER_PREFIX}.${HOST_PREFIX}/ (Portainer)"
	@echo "$(PURPLE)http://redis-insight-${CONTAINER_PREFIX}.${HOST_PREFIX}/ (Redis Insight)"
	@echo "$(FIRE)http://${NODE_01_DOMAIN}.${HOST_PREFIX}:${NODE_01_PORT_EXPOSE}/ (Node App 01)"
	@echo "$(FIRE)http://${NODE_02_DOMAIN}.${HOST_PREFIX}:${NODE_02_PORT_EXPOSE}/ (Node App 02)"

# run composer in contianer of name laravel-app and give the permission to laravel bootstrap and storage folder
composer:
	$(COMPOSE) exec php-app composer install
	$(COMPOSE) exec php-app chmod -R 777 ./

bash-php:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-app /bin/bash
bash-php2:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-app2 /bin/bash
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
# | Meilisearch commands
# |--------------------------------------------------------------------------
# */
meilisearch-moves:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-app /bin/bash -c "php artisan scout:flush 'App\Models\Move' && php artisan scout:import 'App\Models\Move'"
meilisearch-config:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-app /bin/bash -c "php artisan meilisearch:key && meilisearch:config"

# /*
# |--------------------------------------------------------------------------
# | Laravel commands
# |--------------------------------------------------------------------------
# */
horizon:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-app /bin/bash -c "php artisan horizon"
clear-cache:
	@$(DOCKER) exec -it $(CONTAINER_PREFIX)-app /bin/bash -c "php artisan optimize:clear"

# /*
# |--------------------------------------------------------------------------
# | Install Command
# |--------------------------------------------------------------------------
# */
install: network build start start-utility start-nodeapp composer links

uninstall: stop stop-utility stop-nodeapp destroy prune delete-volumes

# Help command
help:
	@echo "$(CYAN)Available commands:$(RESET)"
	@echo "$(YELLOW)---------------Network------------------------------------$(RESET)"
	@echo "$(RED)newtork$(RESET)             : Create Docker network"
	@echo "$(RED)network-list$(RESET)        : List Docker networks"
	@echo "$(YELLOW)---------------Docker Container start and stop commands---$(RESET)"
	@echo "$(RED)start$(RESET)              : Start all containers"
	@echo "$(RED)start-utility$(RESET)      : Start utility containers"
	@echo "$(RED)start-nodeapp$(RESET)      : Start Node App 01 container $(BLUE)$(NODE_01_APP_NAME)"
	@echo "$(RED)start-nodeapp2$(RESET)     : Start Node App 02 container $(BLUE)$(NODE_02_APP_NAME)"
	@echo "$(RED)stop$(RESET)               : Stop all containers"
	@echo "$(RED)stop-utility$(RESET)       : Stop utility containers"
	@echo "$(RED)stop-nodeapp$(RESET)       : Stop Node App 01 container"
	@echo "$(RED)stop-nodeapp2$(RESET)      : Stop Node App 02 container"
	@echo "$(YELLOW)---------------Docker Build--------------------------------$(RESET)"
	@echo "$(RED)build$(RESET)              : Build all containers"
	@echo "$(YELLOW)---------------Docker Cache clear--------------------------$(RESET)"
	@echo "$(RED)destroy$(RESET)            : Remove all containers"
	@echo "$(RED)delete-volumes$(RESET)     : Delete all volumes"
	@echo "$(RED)prune$(RESET)              : Clear Docker system resources"
	@echo "$(YELLOW)---------------Utility commands----------------------------$(RESET)"
	@echo "$(RED)list$(RESET)               : List all containers"
	@echo "$(RED)links$(RESET)              : Show useful links"
	@echo "$(RED)composer$(RESET)           : Run composer install inside PHP container"
	@echo "$(RED)bash-php$(RESET)           : Enter bash shell of PHP container"
	@echo "$(RED)bash-php2$(RESET)          : Enter bash shell of PHP2 container"
	@echo "$(RED)bash-nginx$(RESET)         : Enter bash shell of Nginx container"
	@echo "$(RED)bash-redis$(RESET)         : Enter bash shell of Redis container"
	@echo "$(RED)bash-nodeapp01$(RESET)     : Enter bash shell of Node App 01 container"
	@echo "$(RED)bash-nodeapp02$(RESET)     : Enter bash shell of Node App 02 container"
	@echo "$(YELLOW)---------------Meilisearch commands------------------------$(RESET)"
	@echo "$(RED)meilisearch-moves$(RESET)  : Flush and import Meilisearch index"
	@echo "$(RED)meilisearch-config$(RESET) : Configure Meilisearch"
	@echo "$(YELLOW)---------------Laravel commands----------------------------$(RESET)"
	@echo "$(RED)horizon$(RESET)            : Start Laravel Horizon"
	@echo "$(RED)clear-cache$(RESET)        : Clear Laravel cache"
	@echo "$(YELLOW)---------------Install and Uninstall-----------------------$(RESET)"
	@echo "$(RED)install$(RESET)            : Install all containers"
	@echo "$(RED)uninstall$(RESET)          : Uninstall all containers"
