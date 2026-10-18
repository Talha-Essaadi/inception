COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE = docker compose -f $(COMPOSE_FILE)

all: create
	$(COMPOSE) up -d --build
	
create:
	USER=$(shell whoami)
	mkdir -p /home/$(USER)/data/n8n
	mkdir -p /home/$(USER)/data/mariadb
	mkdir -p /home/$(USER)/data/wordpress


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
	sudo rm -rf /home/$(USER)/data/n8n/*
	sudo rm -rf /home/$(USER)/data/mariadb/*
	sudo rm -rf /home/$(USER)/data/wordpress/*
	$(COMPOSE) down --rmi all --volumes

re:
	sudo rm -rf /home/$(USER)/data/n8n/*
	sudo rm -rf /home/$(USER)/data/mariadb/*
	sudo rm -rf /home/$(USER)/data/wordpress/*
	$(COMPOSE) down --rmi all --volumes
	$(COMPOSE) up -d --build

rr:
	docker compose -f srcs/docker-compose.yml down nginx
	docker compose -f srcs/docker-compose.yml build nginx
	docker compose -f srcs/docker-compose.yml up nginx -d

.PHONY: all build up down start stop restart logs ps clean re
