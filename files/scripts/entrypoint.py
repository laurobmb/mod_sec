import os,re

versao = os.environ['NGINX_VERSION']
frontend = os.environ['FRONTEND']
backend = os.environ['BACKEND']
mode = os.environ['MODE']

# mode 1 = reverse proxy
# mode 2 = forward proxy

if mode == "1":
	print('###### MODE REVERSE PROXY ######\n')
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

elif mode == "2":
	print('###### MODE FORWARD PROXY ######\n')
	input_file="/usr/local/nginx/conf.d/virtualHost_forward_proxy.template"
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
