FROM ubuntu:14.04
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get install -y curl wget openssl redis-server supervisor

ADD install-sensu.sh /tmp/
ADD influxdb-metrics.rb /tmp/
RUN chmod +x /tmp/install-sensu.sh
#RUN /tmp/install-sensu.sh

ADD redis-run.sh /tmp/
ADD supervisor.conf /etc/supervisor/conf.d/sensu.conf

CMD /tmp/redis-run.sh
