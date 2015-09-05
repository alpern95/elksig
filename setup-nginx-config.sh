#!/bin/sh
#Variable for local host
HOSTIPNAME=$(ip a show dev eth0 | grep inet | grep eth0 | sed -e 's/^.*inet.//g' -e 's/\/.*$//g')
cat << EOF > nginx/config/nginx.conf
worker_processes  1;

events {
    worker_connections  1024;
}


http {

    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout 65;
    ssl_certificate     /etc/nginx/ssl/certs/docker-registry.crt;
    ssl_certificate_key /etc/nginx/ssl/private/docker-registry.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ldap_server slapd {
        url ldap://$HOSTIPNAME/dc=example,dc=com?uid?sub?(objectClass=person);
        binddn "cn=admin,dc=example,dc=com";
        binddn_passwd toor;
        group_attribute member;
#        group_attribute_is_dn on;
#        require group 'cn=monitoring,ou=groups,dc=example,dc=com';
        require valid_user;
        satisfy all;
      }

    server {
        listen 443 ssl;
        error_log /usr/local/nginx/logs/error.log;
        access_log /usr/local/nginx/logs/access.log;
        root /usr/share/nginx/html;
            auth_ldap "Forbidden";
            auth_ldap_servers slapd;
        location /grafana/ {
            proxy_pass http://$HOSTIPNAME:4000/;
        }

        location /kibana/ {
            proxy_pass http://$HOSTIPNAME:5601/;
        }

        location /uchiwa/ {
            proxy_pass http://$HOSTIPNAME:3000/;
        }

        location /elasticsearch {
            proxy_pass http://$HOSTIPNAME:9200/;
            add_header 'Access-Control-Allow-Origin' '$HOSTIPNAME:9200';
            add_header 'Access-Control-Allow-Methods' 'GET, POST';
            add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type';
            add_header 'Access-Control-Allow-Credentials' 'true';
        }

        location /influxdb/ {
            proxy_pass http://$HOSTIPNAME:8086/;
            add_header 'Access-Control-Allow-Origin' '$HOSTIPNAME:8086';
            add_header 'Access-Control-Allow-Methods' 'GET, POST';
            add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type';
            add_header 'Access-Control-Allow-Credentials' 'true';
        }
        location /influxdbadmin/ {
            proxy_pass http://$HOSTIPNAME:8083/;
        }
    }
}
EOF
