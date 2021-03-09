#!/bin/bash
echo ""

scripts=(
/usr/local/nginx/conf/owasp-crs/rules/REQUEST-903.9006-XENFORO-EXCLUSION-RULES.conf
/usr/local/nginx/conf/owasp-crs/rules/REQUEST-903.9005-CPANEL-EXCLUSION-RULES.conf
/usr/local/nginx/conf/owasp-crs/rules/REQUEST-903.9004-DOKUWIKI-EXCLUSION-RULES.conf
/usr/local/nginx/conf/owasp-crs/rules/REQUEST-903.9003-NEXTCLOUD-EXCLUSION-RULES.conf
/usr/local/nginx/conf/owasp-crs/rules/REQUEST-903.9002-WORDPRESS-EXCLUSION-RULES.conf
/usr/local/nginx/conf/owasp-crs/rules/REQUEST-903.9001-DRUPAL-EXCLUSION-RULES.conf
)

for i in ${scripts[*]}; do 
    echo -n "Removendo arquivo de regra -> $i"
    rm -f $i
    echo ""
done

echo ""


