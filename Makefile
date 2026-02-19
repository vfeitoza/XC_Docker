.PHONY: help build up down logs install clean restart-mariadb check-nginx check-php check-mariadb finish-db shell

help:
	@echo "Comandos disponíveis:"
	@echo "  make build           - Constrói a imagem Docker"
	@echo "  make up              - Inicia os containers em background"
	@echo "  make down            - Para e remove os containers"
	@echo "  make logs            - Exibe todos os logs em tempo real"
	@echo "  make check-nginx     - Verifica se nginx está rodando (processo)"
	@echo "  make check-php       - Verifica se PHP-FPM está rodando (processo)"
	@echo "  make check-mariadb   - Verifica se MariaDB está rodando (processo)"
	@echo "  make install         - Executa instalação do XC (python3 ./xc_install)"
	@echo "  make clean           - Remove dados dos volumes home e mysql-data"
	@echo "  make start-server    - Inicia o XC no container após a instalação"
	@echo "  make restart-mariadb - Reinicia o serviço MariaDB no container"
	@echo "  make finish-db       - Finaliza ajustes no banco depois de configuração via painel"
	@echo "  make shell           - Loga-se no container para execução de comandos"

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

check-nginx:
	docker compose exec webstack /scripts/status-server.sh nginx

check-php:
	docker compose exec webstack /scripts/status-server.sh php

check-mariadb:
	docker compose exec webstack /scripts/status-server.sh mariadb

install:
	docker compose exec webstack python3 /scripts/xc_install
	docker compose exec webstack /home/xc_vm/service start 2>&1 >/dev/null &
	@echo "XC instalado. Finalize agora via painel web"

clean:
	rm -rf data/home/* data/mysql-data/* data/mysql-etc/*

restart-mariadb:
	docker compose exec webstack /scripts/restart-mariadb.sh

start-server:
	docker compose exec webstack /home/xc_vm/service start 2>&1 >/dev/null &
	@echo "Serviços inciados no Docker"

finish-db:
	docker compose exec webstack /home/xc_vm/status
	
shell:
	docker compose exec webstack bash
