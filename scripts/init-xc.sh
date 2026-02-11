#!/bin/bash

STATUS_FILE="/home/xc_vm/status"
SERVICE="/home/xc_vm/service"

if [ -x "$SERVICE" ]; then
    echo "Sistema instalado. Iniciando serviço..."
    "$SERVICE" start
else
    echo "Sistema não instalado. Inicie a instalaçao"
#    python3 /xc_install
fi
