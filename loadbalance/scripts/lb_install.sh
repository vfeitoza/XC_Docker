#!/bin/bash

LATEST_VERSION=$(curl -s https://api.github.com/repos/Vateron-Media/XC_VM/releases/latest | grep '\"tag_name\":' | cut -d '"' -f 4) 
URL="https://github.com/Vateron-Media/XC_VM/releases/download/${LATEST_VERSION}/loadbalancer.tar.gz"
DESTINO="/tmp/XC_VM.tar.gz"
PASTA="/home/xc_vm"

echo "Baixando arquivo..."
wget -q "$URL" -O "$DESTINO"

# Verifica se o download foi bem sucedido E se o arquivo existe
if [ $? -eq 0 ] && [ -f "$DESTINO" ]; then
    echo "Download concluído com sucesso."

    echo "Descompactando em $PASTA ..."
    mkdir -p "$PASTA"
    tar -xzf "$DESTINO" -C "$PASTA"

    if [ $? -eq 0 ]; then
        echo "Arquivo descompactado com sucesso."
    else
        echo "Erro ao descompactar o arquivo."
        exit 1
    fi
else
    echo "Erro: arquivo não foi baixado corretamente."
    exit 1
fi

echo "Configurando o Load Balance"
cat << 'EOF' > /home/xc_vm/config/config.ini
; XC_VM Configuration
; -----------------

[XC_VM]
hostname    =   "200.9.26.74"
database    =   "xc_vm"
port        =   3306
server_id   =   4
is_lb       =   1

[Encrypted]
username    =   "projetos"
password    =   "projetos@1213"
;username    =   "SKkcwtBaSpZPmgnDJ8euCywwSXjvrFcg"
;password    =   "bsTWYm2jTMgEYaWdFZJxA3QQ7jsAHJJv"
EOF

# Portas web
echo "listen 984;" > /home/xc_vm/bin/nginx/conf/ports/http.conf
echo "listen 985;" > /home/xc_vm/bin/nginx/conf/ports/https.conf

# Setando permissões
chown xc_vm: -R /home/xc_vm

chmod 777 -R /home/xc_vm/bin/php/sockets
chmod 777 -R /home/xc_vm/bin/php/sessions


# Iniciando serviços
/home/xc_vm/service start > /dev/null

# verificando se esta tudo OK
/home/xc_vm/status


