
import os

path='/etc/nginx/modsecurity/rules/'

files=[
    path+'REQUEST-903.9006-XENFORO-EXCLUSION-RULES.conf'
]

print("########## Apagando rules do CRS ##########")
print("########## File is /etc/nginx/modsecurity/rules/ ##########")

for i in files:
    if os.path.isfile(i):
        os.remove(i)
        print("success delete file:",i)
    else:    
        print("File doesn't exists!",i)



