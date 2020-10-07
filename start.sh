#!/bin/bash
echo Executando NgINX com o $FRONTEND e o $BACKEND
python3 /root/entrypoint.py

if nginx -t; then
	#cat /usr/local/nginx/conf.d/virtualHost.conf
	nginx -g 'daemon off;'
else
	echo "Erro !!!!"
fi
