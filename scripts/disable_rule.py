#OBS o numero da regra deve estar correto, caso não esteja o nginx não vai iniciar

print("########## Removendo regras do catalogo de rules do CRS ##########")
print("########## File is /etc/nginx/modsecurity/crs-setup.conf ##########")

file='/etc/nginx/modsecurity/crs-setup.conf'

rules=[954011]

with open(file, "a") as file_object:
    file_object.write('### Editado ao iniciar #### \n')
    for i in rules:
        print('removendo regra número -> ',str(i))
        file_object.write('SecRuleRemoveById '+str(i)+'\n')

print('########## Removendo regras do catalogo de rules do CRS ##########\n')

