#!/bin/bash
echo "Executando NgINX com o FRONTEND: $FRONTEND e o BACKEND: $BACKEND"
echo ""

python3 /root/entrypoint.py

bash /root/remove_files_rules.sh

python3 /root/remove_rules_id.py

if nginx -t; then
	nginx -g 'daemon off;'
else
	echo "Erro !!!!"
fi
