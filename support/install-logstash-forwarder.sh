#!/bin/bash
echo "Adding Logstash-forwarder"
wget https://download.elastic.co/logstash-forwarder/binaries/logstash-forwarder_0.4.0_amd64.deb
dpkg -i logstash-forwarder_0.4.0_amd64.deb
mkdir /etc/pki/
mkdir /etc/pki/tls/
mkdir /etc/pki/tls/certs
mkdir /etc/pki/tls/private/
mkdir /etc/pki/tls/certs/logstash-forwarder/
mkdir /etc/pki/tls/private/logstash-forwarder/
cp logstash/ssl/private/logstash-forwarder.key  /etc/pki/tls/private/logstash-forwarder/logstash-forwarder.key
cp logstash/ssl/certs/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder/logstash-forwarder.crt
echo "Create logstash-forwarder.conf"
cat << EOF > /etc/logstash-forwarder.conf
{
"network": {
  "servers": [ "localhost:5001" ],
  "ssl certificate": "/etc/pki/tls/certs/logstash-forwarder/logstash-forwarder.crt",
  "ssl key": "/etc/pki/tls/private/logstash-forwarder/logstash-forwarder.key",
  "ssl ca": "/etc/pki/tls/certs/logstash-forwarder/logstash-forwarder.crt"
  },
  # The list of files configurations
  "files": [
    # An array of hashes. Each hash tells what paths to watch and
    # what fields to annotate on events from those paths.
    {
      "paths": [
        # single paths are fine
        "/var/log/messages",
        #"/var/log/nginx/access.log",
        #"/var/log/nginx/error.log",
        # globs are fine too, they will be periodically evaluated
        # to see if any new files match the wildcard.
        "/var/log/*.log"
        ],
      # A dictionary of fields to annotate on each event.
      "fields": { "type": "syslog" }
    }
  ]
}
EOF
echo "Launch echo logstash-forwarder"
service logstash-forwarder start
