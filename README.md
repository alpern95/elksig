# elksig

Ddockers: 
Elastic Logstash Kibana Sensu Influxdb Grafana

Docker datcontainer for influxdb, elastic
Docker nginx to proxyfy kibana grafana Uchiwa.
Docker slapd to use with nginx authent module.

This docker composition is inspired from another existing (Hera-Monitoring) from nuance-mobility.

https://github.com/Nuance-Mobility/Hera-Monitoring.

![Architecture](https://github.com/alpern95/elksig/blob/master/ELKSIG.png)

# Getting Started

Installation of docker and docker-compose
 
- https://docs.docker.com/installation/
- https://docs.docker.com/compose/install/

sudo apt-get update

sudo apt-get install wget ldap-utils git

git clone https://github.com/alpern95/elksig.git

cd elksig

