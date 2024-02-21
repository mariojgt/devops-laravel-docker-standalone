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

# run composer in contianer of name laravel-app
composer:
	$(COMPOSE) exec app composer install
