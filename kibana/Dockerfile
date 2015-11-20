FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

# Usual update / upgrade
RUN apt-get update && apt-get upgrade -q -y && apt-get dist-upgrade -q -y

# Let our containers upgrade themselves
RUN apt-get install -q -y unattended-upgrades

# Install Java... eurk
#RUN apt-get install -q -y openjdk-8-jre-headless

RUN apt-get update && \
    apt-get install -y ca-certificates wget

RUN cd /opt && \
    wget https://download.elasticsearch.org/kibana/kibana/kibana-4.2.0-linux-x64.tar.gz && \
    tar -xzvf ./kibana-4.2.0-linux-x64.tar.gz && \
    mv kibana-4.2.0-linux-x64 kibana && \
    rm kibana-4.2.0-linux-x64.tar.gz

ADD conf/kibana.yml /opt/kibana/config/kibana.yml
ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
