ARG NGINX_VERSION=1.19.1

FROM nginx:$NGINX_VERSION-alpine AS builder

ARG MODSECURITY_VERSION=v3.0.4
ARG MODSECURITY_CONNECTOR_VERSION=v1.0.1
ARG CRS_VERSION=3.3.0

RUN apk --update --no-cache add \
        gcc \
        make \
        libc-dev \
        g++ \
        openssl-dev \
        linux-headers \
        pcre-dev \
        zlib-dev \
        libtool \
        automake \
        autoconf \
        lmdb-dev \
        libxml2-dev \
        curl-dev \
        byacc \
        flex \
        yajl-dev \
        geoip-dev \
        libstdc++ \
        libmaxminddb-dev \
        git \
        wget 

RUN cd /opt \
    && git clone --depth 1 -b $MODSECURITY_VERSION --single-branch https://github.com/SpiderLabs/ModSecurity \
    && cd ModSecurity \
    && git submodule update --init \
    && ./build.sh \
    && ./configure \
    && make \
    && make install 

RUN cd /opt \
    && git clone --depth 1 -b $MODSECURITY_CONNECTOR_VERSION --single-branch https://github.com/SpiderLabs/ModSecurity-nginx.git \
    && wget -O - http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar zxfv - \
    && mv /opt/nginx-$NGINX_VERSION /opt/nginx \
    && cd /opt/nginx \
    #&& sed -i 's@"nginx/"@"-/"@g' src/core/nginx.h \
    #&& sed -i 's@r->headers_out.server == NULL@0@g' src/http/ngx_http_header_filter_module.c \
    #&& sed -i 's@r->headers_out.server == NULL@0@g' src/http/v2/ngx_http_v2_filter_module.c \
    #&& sed -i 's@<hr><center>nginx</center>@@g' src/http/ngx_http_special_response.c \
    && sed -i 's/"Server: nginx" CRLF/"Server: sem_versao" CRLF/g' src/http/ngx_http_header_filter_module.c \
    && sed -i 's/"Server: " NGINX_VER CRLF/"Server: sem_versao" CRLF/g' src/http/ngx_http_header_filter_module.c \
    && ./configure --with-compat --add-dynamic-module=/opt/ModSecurity-nginx \
    && make modules 

RUN cd /opt \
    && wget -O - https://github.com/coreruleset/coreruleset/archive/v$CRS_VERSION.tar.gz | tar zxfv - \
    && ls -la /opt \
    && mv /opt/coreruleset-$CRS_VERSION /opt/coreruleset

FROM nginx:$NGINX_VERSION-alpine

COPY --from=0 /opt/nginx/objs/ngx_http_modsecurity_module.so /usr/lib/nginx/modules
COPY --from=0 /opt/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsecurity/modsecurity.conf
COPY --from=0 /opt/coreruleset/crs-setup.conf.example /etc/nginx/modsecurity/crs-setup.conf
COPY --from=0 /opt/coreruleset/rules/ /etc/nginx/modsecurity/rules/
COPY --from=0 /usr/local/modsecurity/ /usr/local/modsecurity/

#https://github.com/SpiderLabs/ModSecurity/issues/1941
COPY --from=0 /opt/ModSecurity/unicode.mapping /etc/nginx/modsecurity/unicode.mapping

RUN apk --update --no-cache add \
        yajl \
        libstdc++ \
        libmaxminddb \
    && rm -rf /var/lib/apt/lists/* \
    && chmod 755 /usr/lib/nginx/modules/ngx_http_modsecurity_module.so \
    && chmod -R 644 \
        /etc/nginx/modsecurity/crs-setup.conf \
        /etc/nginx/modsecurity/rules/* \
    && chmod 755 \
        /etc/nginx/modsecurity/ \
        /etc/nginx/modsecurity/rules \
    && mv /etc/nginx/modsecurity/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example  /etc/nginx/modsecurity/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf \
    && mv /etc/nginx/modsecurity/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example  /etc/nginx/modsecurity/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf \
    && sed -i '1iload_module \/usr\/lib\/nginx\/modules\/ngx_http_modsecurity_module.so;'   /etc/nginx/nginx.conf \
    && sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/'     /etc/nginx/modsecurity/modsecurity.conf \
    && sed -i 's/SecAuditEngine RelevantOnly/SecAuditEngine Off/'   /etc/nginx/modsecurity/modsecurity.conf \
    && echo 'include "/etc/nginx/modsecurity/modsecurity.conf"' >>  /etc/nginx/modsecurity/main.conf \
    && echo 'include "/etc/nginx/modsecurity/crs-setup.conf"' >>    /etc/nginx/modsecurity/main.conf \
    && echo 'include "/etc/nginx/modsecurity/rules/*.conf"' >>      /etc/nginx/modsecurity/main.conf   

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./scripts/ /
COPY ./rules/ /etc/nginx/modsecurity/rules/
COPY ./conf/blacklist.txt /etc/nginx/blacklist.txt
COPY ./conf/proxy_novo.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /usr/share/nginx/html/_v/healthcheck \
    && apk --update --no-cache add \
            bash \
            python3 \
    && ln -sf python3 /usr/bin/python \
    && chmod +x /bootstrap.sh \
    && /bootstrap.sh


