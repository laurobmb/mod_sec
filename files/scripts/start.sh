#!/bin/bash
echo "Executando NgINX com o FRONTEND: $FRONTEND e o BACKEND: $BACKEND"
echo ""
python3 /root/entrypoint.py
bash /root/remove_rules.sh

if nginx -t; then
	nginx -g 'daemon off;'
else
	echo "Erro !!!!"
fi
