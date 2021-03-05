import os,re

versao = os.environ['NGINX_VERSION']
frontend = os.environ['FRONTEND']
backend = os.environ['BACKEND']

input_file="/usr/local/nginx/conf.d/virtualHost.template"
output_file="/usr/local/nginx/conf.d/virtualHost.conf"

with open(output_file,'w') as fd:
	print("Arquivo zerado /usr/local/nginx/conf.d/virtualHost.conf")

with open(input_file,'r') as fd:
	with open(output_file, 'a') as sd:
		for arquivo_de_saida in fd.readlines():
			if 'XXXXXXXXXX' in arquivo_de_saida:
				sd.write(arquivo_de_saida.replace("XXXXXXXXXX", frontend))
			elif 'YYYYYYYY' in arquivo_de_saida:
				sd.write(arquivo_de_saida.replace("YYYYYYYY", backend))
			else:
				sd.write(arquivo_de_saida)

print("Arquivo Completo /usr/local/nginx/conf.d/virtualHost.conf")