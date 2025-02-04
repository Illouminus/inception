COMPOSE_FILE = srcs/docker-compose.yml

all: up

build:
	@echo "Building containers..."
	docker-compose -f $(COMPOSE_FILE) build

up: build
	@echo "Starting containers..."
	docker-compose -f $(COMPOSE_FILE) up -d

down:
	@echo "Stopping containers..."
	docker-compose -f $(COMPOSE_FILE) down

re: down
	@echo "Rebuilding and restarting containers..."
	docker-compose -f $(COMPOSE_FILE) up -d --build

ps:
	@echo "Containers status:"
	docker-compose -f $(COMPOSE_FILE) ps

clean: down
	@echo "Pruning unused Docker resources..."
	docker system prune -a --force --volumes

fclean:
	@echo "Stopping all containers and removing all resources..."
	docker-compose -f $(COMPOSE_FILE) down -v
	-docker stop $$(docker ps -qa)
	docker system prune --all --force --volumes
	docker network prune --force
	docker volume prune --force
	sudo chmod 777 /home/ebaillot/data/wordpress
	sudo chmod 777 /home/ebaillot/data/mariadb
	sudo rm -rf /home/ebaillot/data/wordpress/*
	sudo rm -rf /home/ebaillot/data/mariadb/*

.PHONY: all build up down re ps clean fclean
