#!/bin/bash
echo ""
if [ $MODE == "1" ]; then
	echo "###### Executando NgINX no modo PROXY REVERSO com o FRONTEND: $FRONTEND e o BACKEND: $BACKEND ###### "
elif [ $MODE == "2" ]; then
	echo "###### Executando NgINX no modo FORWARD PROXY ###### "
else
	echo "Modo desconhecido"
fi
echo ""

python3 /root/entrypoint.py

bash /root/remove_files_rules.sh

python3 /root/remove_rules_id.py

if nginx -t; then
	nginx -g 'daemon off;'
else
	echo "Erro !!!!"
fi
