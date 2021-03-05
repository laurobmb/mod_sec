FROM centos:8

LABEL version="3.0.4"
LABEL maintainer="Lauro Gomes <laurobmb@gmail.com>"

ENV NGINX_VERSION="1.19.0"
ENV MOD_SECURITY_VERSION="3.0.4"
ENV MOD_SECURITY_NGINX_VERSION="1.0.1"
ENV CORERULESET="3.3.0"
ENV FRONTEND="server name or IP input"
ENV BACKEND="server name or IP output"
 
RUN dnf -y install \
    gcc-c++ \
    flex \
    bison \
    yajl \
    curl-devel \
    zlib-devel \
    pcre-devel \
    autoconf \
    automake \
    curl \
    make \
    libxml2-devel \
    pkgconfig \
    libtool \
    httpd-devel \
    redhat-rpm-config \
    git \
    wget \
    openssl \
    openssl-devel \
    python38

RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm ;\
    dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm ;\
    dnf -y install dnf-plugins-core ;\
    dnf config-manager --set-enabled powertools ;\
    dnf install -y doxygen yajl-devel ;\
    dnf --enablerepo=remi install -y GeoIP-devel

RUN mkdir -p /opt/modsec/ModSecurity &&\
    wget https://github.com/SpiderLabs/ModSecurity/releases/download/v${MOD_SECURITY_VERSION}/modsecurity-v${MOD_SECURITY_VERSION}.tar.gz  &&\
    tar xzf modsecurity-v${MOD_SECURITY_VERSION}.tar.gz &&\
    mv modsecurity-v${MOD_SECURITY_VERSION}/* /opt/modsec/ModSecurity

RUN cd /opt/modsec/ModSecurity &&\
    ./build.sh &&\
    ./configure &&\
    make &&\
    make install

RUN mkdir /opt/modsec/ModSecurity-nginx &&\
    wget https://github.com/SpiderLabs/ModSecurity-nginx/releases/download/v${MOD_SECURITY_NGINX_VERSION}/modsecurity-nginx-v${MOD_SECURITY_NGINX_VERSION}.tar.gz &&\
    tar xzf modsecurity-nginx-v${MOD_SECURITY_NGINX_VERSION}.tar.gz &&\
    mv modsecurity-nginx-v${MOD_SECURITY_NGINX_VERSION}/* /opt/modsec/ModSecurity-nginx

RUN useradd -r -M -s /sbin/nologin -d /usr/local/nginx nginx

RUN mkdir /opt/nginx-${NGINX_VERSION}

RUN cd /opt/; \
    wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz ;\
    tar xzf nginx-${NGINX_VERSION}.tar.gz

COPY ./files/hide_version.sh /root

RUN chmod +x /root/hide_version.sh && \
    /root/hide_version.sh

RUN cd /opt/nginx-${NGINX_VERSION};\
    ./configure \
    --user=nginx \
    --group=nginx \
    --with-pcre-jit \
    --with-debug \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --add-module=/opt/modsec/ModSecurity-nginx ;\
    make; \
    make install

RUN ln -s /usr/local/nginx/sbin/nginx /usr/sbin/

RUN mkdir /root/.certs/
RUN cd /root/.certs/ ;\
    openssl req -x509 -newkey rsa:4096 \
    -keyout nginx.key \
    -out nginx.crt \
    -days 10000 \
    -nodes \
    -subj "/C=BR/ST=Pernambuco/L=Recife/O=Suporte Conectado/O=SPC/CN=*.conectado.local"

RUN cp /opt/modsec/ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf && \
    cp /opt/modsec/ModSecurity/unicode.mapping /usr/local/nginx/conf/ && \
    mkdir /usr/local/nginx/conf.d/ && \
    mkdir /var/log/nginx/ && \
    mkdir /usr/local/nginx/errorpages && \
    dnf clean all

RUN wget https://github.com/coreruleset/coreruleset/archive/v${CORERULESET}.tar.gz &&\ 
    tar xzf v${CORERULESET}.tar.gz &&\
    mkdir /usr/local/nginx/conf/owasp-crs/ &&\
    cp /coreruleset-${CORERULESET}/crs-setup.conf.example /usr/local/nginx/conf/owasp-crs/crs-setup.conf &&\
    mv /coreruleset-${CORERULESET}/rules /usr/local/nginx/conf/owasp-crs/ &&\
    mv /usr/local/nginx/conf/owasp-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/local/nginx/conf/owasp-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf &&\
    mv /usr/local/nginx/conf/owasp-crs/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example /usr/local/nginx/conf/owasp-crs/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf

COPY ./files/nginx.conf /usr/local/nginx/conf/nginx.conf

COPY ./files/virtualHost.conf /usr/local/nginx/conf.d/

COPY ./files/entrypoint.py /root/

COPY ./files/start.sh /root/

COPY ./files/modsecurity.conf /usr/local/nginx/conf/modsecurity.conf

COPY ./files/errorpages  /usr/local/nginx/errorpages

COPY ./files/virtualHost.template /usr/local/nginx/conf.d/

RUN python3 /root/entrypoint.py  && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80/tcp 443/tcp

CMD [ "bash", "/root/start.sh" ]
