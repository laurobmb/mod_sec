#!/bin/bash

cd /opt/nginx-$NGINX_VERSION

sed -i 's@"nginx/"@"-/"@g' src/core/nginx.h
sed -i 's@r->headers_out.server == NULL@0@g' src/http/ngx_http_header_filter_module.c
sed -i 's@r->headers_out.server == NULL@0@g' src/http/v2/ngx_http_v2_filter_module.c
sed -i 's@<hr><center>nginx</center>@@g' src/http/ngx_http_special_response.c
