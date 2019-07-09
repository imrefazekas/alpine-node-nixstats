FROM mhart/alpine-node:10.15.3

## OS related
RUN apk update && apk add --no-cache make gcc g++ git openssh wget nano python python-dev py-pip build-base linux-headers bash rsyslog rsyslog-tls gmp-dev
RUN npm i -g npm@latest

RUN pip install --upgrade pip
RUN pip install nixstatsagent

## Nixstats related
ADD rsyslog.conf /etc/rsyslog.conf
ADD nixstats.ini /etc/nixstats.ini
ADD 31-nixstats.conf /etc/rsyslog.d/31-nixstats.conf
ADD nixstats.ca /etc/rsyslog.d/keys/nixstats.ca

RUN mkdir -p /var/spool/rsyslog
RUN mkdir -p /etc/rsyslog.d/keys

VOLUME [ "/var/log" ]

## Add scripts
ADD log-setup.sh /log-setup.sh
ADD entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh /log-setup.sh

ENTRYPOINT ["/entrypoint.sh"]
