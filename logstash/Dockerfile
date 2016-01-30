#FROM dockerfile/java:oracle-java7
FROM anapsix/docker-oracle-java8

RUN apt-get update && \
    apt-get install -y curl wget

ADD ./conf.d/logstash.conf /etc/logstash/logstash.conf
ADD ./conf.d/logstash-forwarder.crt /etc/logstash/logstash-forwarder.crt
ADD ./conf.d/logstash-forwarder.key /etc/logstash/logstash-forwarder.key
RUN mkdir /etc/logstash/patterns
ADD ./patterns/nginx /etc/logstash/patterns/nginx
ENV LOGSTASH_VERSION 2.1.0
#RUN curl -s "https://download.elastic.co/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz" | \
RUN curl -s "https://download.elastic.co/logstash/logstash/logstash-all-plugins-${LOGSTASH_VERSION}.tar.gz" | \
    tar xz -C /opt && \
    mv "/opt/logstash-${LOGSTASH_VERSION}" /opt/logstash

VOLUME          /etc/logstash/mib
VOLUME          /etc/logstash/conf.d
VOLUME          /etc/pki/tls
VOLUME          /etc/logstash/patterns

ENTRYPOINT ["/opt/logstash/bin/logstash"]
CMD ["-f", "/etc/logstash/conf.d/logstash.conf"]
