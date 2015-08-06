FROM ubuntu:14.04
MAINTAINER Alexandre Viau <alexandre@alexandreviau.net>

RUN apt-get update && apt-get -y install libfontconfig wget adduser openssl ca-certificates
RUN wget http://grafanarel.s3.amazonaws.com/builds/grafana_2.1.0-pre1_amd64.deb
RUN dpkg -i grafana_2.1.0-pre1_amd64.deb

EXPOSE 3000

ENV GF_SERVER_ROOT_URL=https://10.0.163.173/grafana
ENV GF_SECURITY_ADMIN_PASSWORD=admin
ENV GF_AUTH_BASIC_ENABLED=false

ADD install-sensu.sh /tmp/
RUN chmod +x /tmp/install-sensu.sh
RUN /tmp/install-sensu.sh

ADD supervisor.conf /etc/supervisor/conf.d/supervisord.conf
ADD sensu-run.sh /tmp/
WORKDIR /usr/share/grafana
VOLUME ["/var/lib/grafana/dashboards"]
VOLUME ["/data"]
ENTRYPOINT ["/usr/sbin/grafana-server", "--config", "/etc/grafana/grafana.ini"]
CMD ["/tmp/sensu-run.sh"]
