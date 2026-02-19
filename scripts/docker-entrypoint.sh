#!/bin/bash
set -e

# Verifica se a pasta de dados existe (se não, é a primeira vez)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Iniciando instalação inicial do MariaDB..."
    
    # 1. Cria a estrutura de dados
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    echo "Configurando senha de root para vazia..."
    
    # 2. Inicia o banco em modo temporário (em background)
    # O mysqld_safe é bom para isso, pois garante que o processo suba
    mysqld_safe --skip-grant-tables &

    # Espera o banco ficar pronto (o sleep 5 do seu script serve para isso)
    sleep 5

    # 3. Executa seus comandos SQL
    # Opcional: Alterar o plugin de autenticação para 'mysql_native_password' 
    # facilita a conexão antiga via TCP sem senha, mas seu comando atual já funciona.
    mysql -e "FLUSH PRIVILEGES;"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '';"
    # Se quiser permitir acesso root remoto sem senha (perigoso, mas comum em legados):
    # mysql -e "CREATE USER IF NOT EXISTS 'root'@'%';"
    # mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
    mysql -e "FLUSH PRIVILEGES;"

    echo "Configuração finalizada. Parando banco temporário..."

    # 4. Para o banco temporário
    mysqladmin shutdown
    sleep 2
    
    echo "Banco pronto para ser gerenciado pelo Supervisor."
fi

# IMPORTANTE: Não rodamos o mysqld aqui!
# Apenas saímos do script para o Dockerfile continuar e executar o CMD
exec "$@"
