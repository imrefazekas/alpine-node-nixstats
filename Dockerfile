FROM mhart/alpine-node:latest

## OS related
RUN apk update && apk add --no-cache make gcc g++ git openssh wget nano python python-dev py-pip build-base linux-headers bash
RUN apk add rsyslog rsyslog-tls
RUN npm i -g npm@latest
RUN pip install --upgrade pip
RUN pip install nixstatsagent

ADD rsyslog.conf /etc/rsyslog.conf
ADD nixstats.ini /etc/nixstats.ini

EXPOSE 514 514/udp
VOLUME [ "/var/log", "/etc/rsyslog.d" ]

ARG NIXSTATS_USERID=INVALID
ENV NIXSTATS_USERID="${NIXSTATS_USERID}"

ARG NIXSTATS_LOGID=INVALID
ENV NIXSTATS_LOGID="${NIXSTATS_USERID}"

RUN mkdir /app
WORKDIR /app
## RUN wget -q -N https://www.nixstats.com/log.sh
COPY log.sh /app
RUN bash log.sh -u $NIXSTATS_LOGID

RUN nixstatshello $NIXSTATS_USERID /etc/nixstats-token.ini

ENTRYPOINT [ "rsyslogd", "-n" ]
## RUN nohup bash -c "nixstatsagent &"
