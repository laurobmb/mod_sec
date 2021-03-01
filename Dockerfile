FROM centos:8

LABEL version="3.0.4"
LABEL maintainer="Lauro Gomes <laurobmb@gmail.com>"

ENV VERSAO="1.19.0"
ENV FRONTEND="cadastro.laurodepaula.com.br"
ENV BACKEND="fastapi:8000"
 
RUN dnf -y install \
    gcc-c++ \
    flex \
    bison \
    yajl \
    curl-devel \
    curl \
    zlib-devel \
    pcre-devel \
    autoconf \
    automake \
    git \
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
    vim \
    nano \
    python38

RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
RUN dnf -y install dnf-plugins-core
RUN dnf config-manager --set-enabled powertools
RUN dnf install -y doxygen yajl-devel
RUN dnf --enablerepo=remi install -y GeoIP-devel

RUN mkdir -p /opt/modsec/ModSecurity
RUN git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /opt/modsec/ModSecurity

RUN cd /opt/modsec/ModSecurity ;\
    git submodule init ;\
    git submodule update ;\
    ./build.sh; \
    ./configure; \
    make ;\
    make install;

RUN mkdir /opt/modsec/ModSecurity-nginx;\
    cd /opt/modsec;\
    git clone https://github.com/SpiderLabs/ModSecurity-nginx.git

RUN useradd -r -M -s /sbin/nologin -d /usr/local/nginx nginx

RUN mkdir /opt/nginx-${VERSAO}

RUN cd /opt/; \
    wget http://nginx.org/download/nginx-${VERSAO}.tar.gz ;\
    tar xzf nginx-${VERSAO}.tar.gz

RUN cd /opt/nginx-${VERSAO};\
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

RUN cp /opt/modsec/ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf
RUN cp /opt/modsec/ModSecurity/unicode.mapping /usr/local/nginx/conf/

COPY ./files/nginx.conf /usr/local/nginx/conf/nginx.conf

RUN mkdir /usr/local/nginx/conf.d/

COPY ./files/virtualHost.conf /usr/local/nginx/conf.d/

COPY ./files/virtualHost.template /usr/local/nginx/conf.d/

RUN mkdir /var/log/nginx/

COPY ./files/modsecurity.conf /usr/local/nginx/conf/modsecurity.conf

#RUN git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/local/nginx/conf/owasp-crs

RUN git https://github.com/coreruleset/coreruleset.git /usr/local/nginx/conf/owasp-crs

RUN cp /usr/local/nginx/conf/owasp-crs/crs-setup.conf.example /usr/local/nginx/conf/owasp-crs/crs-setup.conf

COPY ./files/entrypoint.py /root/

COPY ./files/start.sh /root/

RUN python3 /root/entrypoint.py

RUN dnf clean all

RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80/tcp

EXPOSE 443/tcp

CMD [ "bash", "/root/start.sh" ]
