FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

# Usual update / upgrade
RUN apt-get update && apt-get upgrade -q -y && apt-get dist-upgrade -q -y

# Let our containers upgrade themselves
RUN apt-get install -q -y unattended-upgrades

# Install usual tools
RUN apt-get install -q -y wget vim

# Install Java... eurk
RUN apt-get install -q -y openjdk-7-jre-headless

RUN wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
	echo "deb http://packages.elasticsearch.org/elasticsearch/1.5/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch.list && \
	apt-get update && apt-get install elasticsearch && \
	mkdir -p /usr/share/elasticsearch/config && \
    ln -s /etc/elasticsearch/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml && \
    ln -s /etc/elasticsearch/logging.yml /usr/share/elasticsearch/config/logging.yml

#VOLUME ["/var/lib/elasticsearch"]
VOLUME ["data"]
VOLUME          /etc/elasticsearch
VOLUME          /usr/share/elasticsearch/data

ADD elasticsearch.default /etc/default/elasticsearch
ADD elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

EXPOSE 9200

RUN /usr/share/elasticsearch/bin/plugin -i elasticsearch/marvel/latest

ENTRYPOINT ["/usr/share/elasticsearch/bin/elasticsearch"]
