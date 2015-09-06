#!/bin/bash
echo "Adding Sensu Apt Repo"
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
echo "deb http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

apt-get update && apt-get install -y git-core sensu
echo "sensu hold" | dpkg --set-selections

cat << EOF > /etc/default/sensu
  EMBEDDED_RUBY=true
  LOG_LEVEL=info
EOF
echo "Installed Sensu"
ln -sf /opt/sensu/embedded/bin/ruby /usr/bin/ruby
/opt/sensu/embedded/bin/gem install redphone --no-rdoc --no-ri
/opt/sensu/embedded/bin/gem install mail --no-rdoc --no-ri --version 2.5.4
/opt/sensu/embedded/bin/gem install bunny --no-rdoc --no-ri
/opt/sensu/embedded/bin/gem install net-ping --no-rdoc --no-ri
rm -rf /etc/sensu/plugins /tmp/sensu_plugins
git clone https://github.com/sensu/sensu-community-plugins.git /tmp/sensu_plugins

cp -Rpf /tmp/sensu_plugins/plugins /etc/sensu/
find /etc/sensu/plugins/ -name *.rb -exec chmod +x {} \;

mkdir -p /etc/sensu/ssl

echo "Configuration sensu client"
HOSTIPNAME=$(ip a show dev eth0 | grep inet | grep eth0 | sed -e 's/^.*inet.//g' -e 's/\/.*$//g')
RABBITMQ_PASSWD=changeme
cat << EOF > /etc/sensu/elksig-config.json
{
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "/usr/local/etc/elksig/client/cert.pem",
      "private_key_file": "/usr/local/etc/elksig/client/key.pem"
    },
    "port": 5671,
    "host": "$HOSTIPNAME",
    "user": "sensu",
    "password": "$RABBITMQ_PASSWD",
    "vhost": "/sensu"
  },
  "client": {
    "name": "elksig",
    "address": "$HOSTNAME",
    "subscriptions": [ "default", "default-metrics" ]
  }
}
EOF
/opt/sensu/embedded/bin/gem install net-snmp
/opt/sensu/embedded/bin/gem install snmp
cp support/snmp-if-metrics.rb /etc/sensu/plugins/snmp/snmp-if-metrics.rb

echo "Launching sensu-client"
/opt/sensu/embedded/bin/ruby /opt/sensu/bin/sensu-client -c /etc/sensu/elksig-config.json -d /etc/sensu -e /etc/sensu/extensions -v -l /var/log/sensu
/elksig-client.log -b

echo "Next steps are:"

echo "  * Retrieve the RabbitMQ password from"
echo "    /usr/local/etc/sensu-docker/sensu.env on the server."
echo "  * modify /etc/sensu/config.json with your Sensu RabbitMQ host and password."
echo "  * Create a unique name and add the hostname of this node"
echo "    for the 'client' section of /etc/sensu/conf.d/config.json."
echo "  * mkdir -p /etc/sensu/ssl"
echo "  * copy /usr/local/etc/client/{cert,key}.pem from the server to /etc/sensu/ssl"
echo "  * sudo service sensu-client start"
echo ""
echo "Now watch the Uchiwa dashbard of the server for the node to join."
