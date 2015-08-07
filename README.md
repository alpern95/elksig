# elksig

# NOT YET READY

Dockers:
 
Elastic Logstash Kibana Sensu Influxdb Grafana

Docker:

Datcontainer for influxdb and for elastic
Docker nginx to proxify kibana grafana Uchiwa.
Docker slapd to use with nginx authent module.

This docker composition is inspired from another existing (Hera-Monitoring) from nuance-mobility.

https://github.com/Nuance-Mobility/Hera-Monitoring.

![Architecture](https://github.com/alpern95/elksig/blob/master/ELKSIG.png)

# Getting Started

Installation of docker and docker-compose
 
- https://docs.docker.com/installation/
- https://docs.docker.com/compose/install/


## utils and git

```
sudo apt-get update

sudo apt-get install wget curl ldap-utils git

sudo -s

git clone https://github.com/alpern95/elksig.git

```

## Installation docker datacontainer and slapd

```
cd elksig
./setup-datacontainer.sh
```

## Lauch datacontainer

```
docker-compose -f data-containers.yml up -d
Setup ldap
./setup-ldap-config.sh
```

## Test ldpa
```
ldapsearch -h localhost -p 389 -xLLL -b "dc=example,dc=com" uid=admin sn givenName cn
```

