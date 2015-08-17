FROM ubuntu:14.04

RUN apt-get update && apt-get -y install libfontconfig wget adduser openssl ca-certificates && apt-get clean
RUN wget http://grafanarel.s3.amazonaws.com/builds/grafana_latest_amd64.deb
RUN dpkg -i grafana_latest_amd64.deb
EXPOSE 3000

ENV GF_SERVER_ROOT_URL=https://10.0.163.173/grafana
ENV GF_SECURITY_ADMIN_PASSWORD=admin
ENV GF_AUTH_BASIC_ENABLED=false

VOLUME ["/var/lib/grafana"]
VOLUME ["/var/log/grafana"]
VOLUME ["/etc/grafana"]

WORKDIR /usr/share/grafana

ENTRYPOINT ["/usr/sbin/grafana-server", "--config=/etc/grafana/grafana.ini", "cfg:default.paths.data=/var/lib/grafana", "cfg:default.paths.logs=/var/log/grafana"]



