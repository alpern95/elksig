#!/bin/bash
cat << EOF > /etc/sensu/grafana-config.json
{
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "/usr/local/etc/sensu-docker/client/cert.pem",
      "private_key_file": "/usr/local/etc/sensu-docker/client/key.pem"
    },
    "port": 5671,
    "host": "$RABBITMQ_PORT_5671_TCP_ADDR",
    "user": "sensu",
    "password": "$RABBITMQ_PASSWD",
    "vhost": "/sensu"
  },
  "client": {
    "name": "sensu-metrics-grafana",
    "address": "$HOSTNAME",
    "subscriptions": [ "default", "default-metrics" ]
  }
}
EOF
cd grafana-${GRAFANA_VERSION}
function setup_grafana {
    sed -i "s|<-- GRAFANA_ROOT_URL -->|${GRAFANA_ROOT_URL}|" /grafana.ini
    sed -i "s|<-- GRAFANA_AUTH_PROXY_ENABLED -->|${GRAFANA_AUTH_PROXY_ENABLED}|" /grafana.ini
    sed -i "s|<-- GRAFANA_AUTH_PROXY_HEADER_NAME -->|${GRAFANA_AUTH_PROXY_HEADER_NAME}|" /grafana.ini

    echo -e "Grafana configured."
}
setup_grafana
./bin/grafana-server -config="/grafana.ini"
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
