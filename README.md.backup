[![Docker Repository on Quay](https://quay.io/repository/laurobmb/mod_sec/status "Docker Repository on Quay")](https://quay.io/repository/laurobmb/mod_sec)


# PROXY PASS Nginx with mod_security 

Este projeto tem a finalidade de provê uma segurança a nível de aplicação usando um firewall de aplicações web open-source [mod-security](https://www.modsecurity.org/), está aplicação de segurança esta no mercado a muitos anos e continua atualizando suas listas e repositórios de regras. Ainda nesse projeto adicionamos regras que cobrem os itens do [OWASP top 10](https://owasp.org/www-project-modsecurity-core-rule-set/), com isso tentamos reduzir ao máximo a superfície de ataque a aplicação.


### Usage 

	podman pull quay.io/laurobmb/mod_sec

### Start container
#### env definitions 

	FRONTEND = dns that should receive the connections, the NGINX virtual host 
	BACKEND = destination webapp

#### pod command 

	podman run -it -p80:80 -p443:443 \
		-e FRONTEND=cadastro.laurodepaula.com.br \	
		-e BACKEND="www2.recife.pe.gov.br" quay.io/laurobmb/mod_sec

    podman run -it -p80:80 -p443:443 \
        -e FRONTEND="www.w0rm30.seg.br" \
        -e BACKEND="127.0.0.1:8080" \
        localhost/mod-sec:latest
        
    docker run -it -p80:80 -p443:443 \
        -e FRONTEND="ilcm.glpi.com" \
        -e BACKEND="lbglpi-1785284617.us-east-1.elb.amazonaws.com" \
        waf:latest

#### Start VM

#### Deploy ansible host 

> ansible-playbook -e frontend=cadastro.laurodepaula.com.br -e backend=www2.recife.pe.gov.br mod_security_install.yml

###### test

> http://cadastro.laurodepaula.com.br/?exec=/bin/bash

> http://cadastro.laurodepaula.com.br/?q="><script>alert(1)</script>"


#### Log verify

> [root@4d16582f7e36 /]# cat /var/log/nginx/modsec_audit.log 

```
ModSecurity: Warning. Matched "Operator `Rx' with parameter `(?i:(?:<\w[\s\S]*[\s\/]|['\"](?:[\s\S]*[\s\/])?)(?:on(?:d(?:e(?:vice(?:(?:orienta|mo)tion|proximity|found|light)|livery(?:success|error)|activate)|r(?:ag(?:e(?:n(?:ter|d)|xit)|(?:gestur|leav)e|start|d (3146 characters omitted)' against variable `ARGS:q' (Value: `"><script>alert(1)</script>"' ) [file "/usr/local/nginx/conf/owasp-crs/rules/REQUEST-941-APPLICATION-ATTACK-XSS.conf"] [line "205"] [id "941160"] [rev ""] [msg "NoScript XSS InjectionChecker: HTML Injection"] [data "Matched Data: <script found within ARGS:q: "><script>alert(1)</script>""] [severity "2"] [ver "OWASP_CRS/3.2.0"] [maturity "0"] [accuracy "0"] [tag "application-multi"] [tag "language-multi"] [tag "platform-multi"] [tag "attack-xss"] [tag "paranoia-level/1"] [tag "OWASP_CRS"] [tag "OWASP_CRS/WEB_ATTACK/XSS"] [tag "WASCTC/WASC-8"] [tag "WASCTC/WASC-22"] [tag "OWASP_TOP_10/A3"] [tag "OWASP_AppSensor/IE1"] [tag "CAPEC-242"] [hostname "10.88.0.31"] [uri "/"] [unique_id "1601988438"] [ref "o2,7v8,28t:utf8toUnicode,t:urlDecodeUni,t:htmlEntityDecode,t:jsDecode,t:cssDecode,t:removeNulls"]
```



### Sources

* https://owasp.org/www-project-modsecurity-core-rule-set/
* https://www.modsecurity.org/
* https://www.nginx.com/blog/compiling-and-installing-modsecurity-for-open-source-nginx/