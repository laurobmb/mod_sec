
import os

path='/etc/nginx/modsecurity/rules/'

files=[
    path+'REQUEST-903.9006-XENFORO-EXCLUSION-RULES.conf',
    path+'REQUEST-903.9005-CPANEL-EXCLUSION-RULES.conf',
    path+'REQUEST-903.9004-DOKUWIKI-EXCLUSION-RULES.conf',
    path+'REQUEST-903.9003-NEXTCLOUD-EXCLUSION-RULES.conf',
    path+'REQUEST-903.9002-WORDPRESS-EXCLUSION-RULES.conf',
    path+'REQUEST-903.9001-DRUPAL-EXCLUSION-RULES.conf'
]

print("########## Apagando rules do CRS ##########")
print("########## File is /etc/nginx/modsecurity/rules/ ##########")

for i in files:
    if os.path.isfile(i):
        os.remove(i)
        print("success delete file:",i)
    else:    
        print("File doesn't exists!",i)



