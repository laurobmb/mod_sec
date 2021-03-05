#OBS o numero da regra deve estar correto, caso não esteja o nginx não vai iniciar

print("########## Removendo regras do catalogo de rules do CRS ##########")
print("########## File is /usr/local/nginx/conf/owasp-crs/crs-setup.conf ########## \n ")

file='/usr/local/nginx/conf/owasp-crs/crs-setup.conf'
rules=[954011,954012,954100,954110,954120,954130,954013,954014,954015,954016,954017,954018]

with open(file, "a") as file_object:
    file_object.write('### Editado ao iniciar #### \n')
    for i in rules:
        print('removendo regra',str(i))
        file_object.write('SecRuleRemoveById '+str(i)+'\n')

print('########## Removendo regras do catalogo de rules do CRS ##########\n')
