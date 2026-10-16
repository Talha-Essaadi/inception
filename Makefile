COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE = docker compose -f $(COMPOSE_FILE)

all: create
	$(COMPOSE) up -d --build
	
create:
	mkdir -p /home/tessaadi/data/mariadb
	mkdir -p /home/tessaadi/data/wordpress


build: create
	$(COMPOSE) build

up: create
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

restart:
	$(COMPOSE) restart

logs:
	$(COMPOSE) logs

ps:
	$(COMPOSE) ps

clean:
	sudo rm -rf /home/tessaadi/data/mariadb/*
	sudo rm -rf /home/tessaadi/data/wordpress/*
	$(COMPOSE) down --rmi all --volumes

re: create
	sudo rm -rf /home/tessaadi/data/mariadb/*
	sudo rm -rf /home/tessaadi/data/wordpress/*
	$(COMPOSE) down --rmi all --volumes
	$(COMPOSE) up -d --build

.PHONY: all build up down start stop restart logs ps clean re
