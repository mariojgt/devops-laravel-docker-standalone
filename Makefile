.PHONY: start stop build

COMPOSE=sudo docker-compose

network:
	sudo docker network create traefik-net

start:
	$(COMPOSE) up -d

stop:
	$(COMPOSE) -f docker-compose.yml down

build:
	$(COMPOSE) build

destroy:
	$(COMPOSE) down --rmi all

list:
	$(COMPOSE) ps -a

# run composer in contianer of name laravel-app and give the permission to laravel bootstrap and storage folder
composer:
	$(COMPOSE) exec app composer install
	$(COMPOSE) exec app chmod -R 777 storage bootstrap/cache

