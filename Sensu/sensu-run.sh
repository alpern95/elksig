#!/bin/sh
#Variable fot mailing with ponymailer
PONYMAILER_SMTP_HOSTNAME=smtp.exemple.com
PONYMAILER_SMTP_USERNAME=no@gmail.com
PONYMAILER_SMTP_FROMNAME=no@gmail.com
PONYMAILER_SMTP_PASSWORD=changeme
PONYMAILER_SMTP_RECIPIENTS=no@gmail.com

UCHIWA_USER=${UCHIWA_USER:-admin}
UCHIWA_PASS=${UCHIWA_PASS:-sensu}
SENSU_HOST=${SENSU_HOST:-localhost}
UCHIWA_CONFIG_URL=${UCHIWA_CONFIG_URL:-}
SKIP_CONFIG=${SKIP_CONFIG:-}
SENSU_METRICS=${SENSU_METRICS:-}
SENSU_CONFIG_URL=${SENSU_CONFIG_URL:-}
SENSU_CLIENT_CONFIG_URL=${SENSU_CLIENT_CONFIG_URL:-}

if [ ! -z "$SENSU_CONFIG_URL" ] ; then
  wget --no-check-certificate -O /etc/sensu/config.json $SENSU_CONFIG_URL
else
  cat << EOF > /etc/sensu/docker-config.json
  {
    "rabbitmq": {
      "ssl": {
        "cert_chain_file": "/usr/local/etc/elksig/client/cert.pem",
        "private_key_file": "/usr/local/etc/elksig/client/key.pem"
      },
      "port": 5671,
      "host": "$RABBITMQ_PORT_5671_TCP_ADDR",
      "user": "sensu",
      "password": "$RABBITMQ_PASSWD",
      "vhost": "/sensu"
    },
    "redis": {
      "host": "$REDIS_PORT_6379_TCP_ADDR",
      "port": 6379
    },
    "api": {
      "host": "$SENSU_HOST",
      "port": 4567
    },
    "handlers": {
      "default": {
        "type": "pipe",
        "command": "true"
      },
      "mailer": {
        "type": "pipe",
        "command": "/opt/sensu/embedded/bin/ruby /etc/sensu/handlers/ponymailer.rb"
      }
    },
    "client": {
      "name": "sensu-server",
      "address": "$HOSTNAME",
      "subscriptions": [ "default", "sensu" ]
    }
  }
EOF
  echo "Wrote out /etc/sensu/config.json"
fi

if [ ! -z "$UCHIWA_CONFIG_URL" ] ; then
  wget --no-check-certificate -O /etc/sensu/uchiwa.json $UCHIWA_CONFIG_URL
else
  cat << EOF > /etc/sensu/uchiwa.json
    {
      "sensu": [
        {
          "name": "Sensu",
          "host": "$SENSU_HOST",
          "ssl": false,
          "port": 4567,
          "user": "",
          "pass": "",
          "path": "",
          "timeout": 5000
        }
      ],
      "uchiwa": {
        "host": "0.0.0.0",
        "port": 3000,
        "user": "$UCHIWA_USER",
        "password": "$UCHIWA_PASS",
        "refresh": 5
      }
    }
EOF
  echo "Wrote out /etc/sensu/uchiwa.json"
fi

cat << EOF > /etc/sensu/conf.d/sensu-client.json
  {
     "checks": {
        "sensu-client": {
          "handlers": [
          "default", "mailer"
          ],
          "command": "/etc/sensu/plugins/processes/check-procs.rb -p sensu-client -C 1 -w 6 -c 8",
          "interval": 60,
          "occurrences": 2,
          "refresh": 300,
          "subscribers": [ "default" ]
        }
     }
  }
EOF

cat << EOF > /etc/sensu/conf.d/sensu-server.json
  {
    "checks": {
      "sensu-server": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p sensu-server -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu" ]
      },
      "sensu-api": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p sensu-api -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu" ]
      },
      "uchiwa": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p uchiwa -C 1 -w 1 -c 1",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu" ]
      },
      "sensu-redis": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p redis-server -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu-redis" ]
      },
      "sensu-rabbitmq-beam": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p beam -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu-rabbitmq" ]
      },
      "sensu-rabbitmq-epmd": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p epmd -C 1 -w 1 -c 1",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu-rabbitmq" ]
      }
    }
  }
EOF

# Set by the metrics.yml
if [ ! -z "$SENSU_METRICS" ] ; then

  echo "Setting Up InfluxDB Handler"
  cp /tmp/sensu_plugins/handlers/metrics/influxdb-metrics.rb /etc/sensu/handlers
  cp /tmp/influxdb.rb /etc/sensu/handlers
  cp /tmp/influxdb-extension.rb /etc/sensu/extensions
  /opt/sensu/embedded/bin/gem install influxdb --no-rdoc --no-ri
  cat << EOF > /etc/sensu/conf.d/influxdb-extension.json
  {
    "influxdb-extension": {
        "hostname": "$INFLUXDB_PORT_8086_TCP_ADDR",
        "port": "$INFLUXDB_PORT_8086_TCP_PORT",
        "database": "sensu",
        "username": "sensu",
        "password": "$INFLUXDB_SENSU_PASSWD"
    }
  }
EOF
  echo "Wrote out /etc/sensu/conf.d/influxdb-extension.json"
  cat << EOF > /etc/sensu/conf.d/influxdb-metrics.json
  {
    "influxdb": {
      "server": "$INFLUXDB_PORT_8086_TCP_ADDR",
      "port": "$INFLUXDB_PORT_8086_TCP_PORT",
      "username": "sensu",
      "password": "$INFLUXDB_SENSU_PASSWD",
      "database": "sensu"
    }
  }
EOF
  echo "Wrote out /etc/sensu/conf.d/influxdb-metrics.json"

  cat << EOF > /etc/sensu/conf.d/influxdb-handler.json
  {
    "handlers": {
      "influxdb": {
        "type": "set",
        "handlers": [ "influxdb-extension" ]
      }
    }
  }
EOF
  echo "Wrote out /etc/sensu/conf.d/config-relay.json"

  cat << EOF > /etc/sensu/conf.d/sensu-metrics.json
  {
    "checks": {
      "sensu-metrics-grafana": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p apache2 -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu-metrics-grafana" ]
      },
      "cpu_metrics": {
        "type": "metric",
        "handlers": [ "influxdb" ],
        "command": "/etc/sensu/plugins/system/cpu-metrics.rb",
        "interval": 60,
        "subscribers": [ "default-metrics" ]
      },
      "load_metrics": {
        "type": "metric",
        "handlers": [ "influxdb" ],
        "command": "/etc/sensu/plugins/system/load-metrics.rb",
        "interval": 60,
        "subscribers": [ "default-metrics" ]
      },
      "memory_metrics": {
        "type": "metric",
        "handlers": [ "influxdb" ],
        "command": "/etc/sensu/plugins/system/memory-metrics.rb",
        "interval": 60,
        "subscribers": [ "default-metrics" ]
      },
      "interface_metrics": {
        "type": "metric",
        "handlers": [ "influxdb" ],
        "command": "/etc/sensu/plugins/system/interface-metrics.rb",
        "interval": 60,
        "subscribers": [ "default-metrics" ]
      },
      "disk_capacity_metrics":{
        "type": "metric",
        "handlers": [ "influxdb" ],
        "command": "/etc/sensu/plugins/system/disk-capacity-metrics.rb",
        "interval": 60,
        "subscribers": [ "default-metrics" ]
      },
       "interface-RT-INFOG-3": {
         "type": "metric",
         "handlers": [ "influxdb" ],
         "command": "/etc/sensu/plugins/snmp/snmp-if-metrics.rb -h 100.254.2.65 -C changeme -e -n -s RT-INFOG-3",
         "interval": 60,
         "source": "RT-INFOG-3",
         "subscribers": [ "reseau"]
      },
        "interface-RT-INFOG-2": {
          "type": "metric",
          "handlers": [ "influxdb" ],
          "command": "/etc/sensu/plugins/snmp/snmp-if-metrics.rb -h 100.254.2.67 -C changeme -e -n -s RT-INFOG-2",
          "interval": 60,
          "source": "RT-INFOG-2",
          "subscribers": [ "reseau"]
       }
    }
  }
EOF
  echo "Wrote out /etc/sensu/conf.d/sensu-metrics.json"
  echo "Setting Up Pony Mailer Handler"

 cp /tmp/sensu_plugins/handlers/notification/ponymailer.rb /etc/sensu/handlers
  
  /opt/sensu/embedded/bin/gem install timeout --no-rdoc --no-ri
  /opt/sensu/embedded/bin/gem install pony --no-rdoc --no-ri

  cat << EOF > /etc/sensu/conf.d/ponymailer.json
{
	"ponymailer": {
		"authenticate":true,
		"only_send_on_change":false,
		"username":"$PONYMAILER_SMTP_USERNAME",
		"tls":true,
		"port":"587",
		"fromname":"$PONYMAILER_SMTP_FROMNAME",
		"hostname":"$PONYMAILER_SMTP_HOSTNAME",
		"password":"$PONYMAILER_SMTP_PASSWORD",
		"from":"$PONYMAILER_SMTP_FROMNAME",
		"recipients":[
                  "$PONYMAILER_SMTP_RECIPIENTS"
                ]
	}
}
EOF
  echo "Wrote out /etc/sensu/conf.d/ponymailer.json"


cat << EOF > /etc/sensu/conf.d/docker-metrics.json
  {
    "checks": {
      "docker": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/docker/check-container-metrics.rb",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "docker-metrics" ]
      }
    }
  }
EOF
  echo "Wrote out /etc/sensu/conf.d/docker-metrics.json"

fi

/usr/bin/supervisord -c /etc/supervisor/conf.d/sensu.conf
