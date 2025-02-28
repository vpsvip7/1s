#!/bin/bash
# MAUVADAO
# VER: 1.0.0
# INSTALANDO SERVIDOR BACKEND

# Instalando o servidor
_nginx(){
apt install -y nginx
}

_config(){
cd /etc/nginx
chmod 777 * -R
cat <<EOF
user www-data;
worker_processes 32;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
 worker_connections 2048;
 multi_accept on;
}

# /etc/nginx/nginx.conf

http {
    server {
        listen 80;

        location / {
        if ($http_backend = "app1") {
                proxy_pass http://127.0.0.1:8080;
             break;
            }

        location /app1 {
            proxy_pass http://2.v202.shop;
        }

        location / {
            proxy_pass http://127.0.0.1:8080;
        }

    }
}
}
EOF
# nginx.conf
# comandos pos configuração
# Verificar se o nginx está funcionando corretamente
# nginx -t

# Atualizar as configurações do nginx
# service nginx reload
}