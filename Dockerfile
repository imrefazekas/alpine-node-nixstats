FROM mhart/alpine-node:latest

## OS related
RUN apk update && apk add --no-cache make gcc g++ git openssh wget nano python python-dev py-pip build-base linux-headers bash
RUN npm i -g npm@latest
RUN pip install --upgrade pip
RUN pip install nixstatsagent

ARG NIXSTATS_USERID=INVALID
ENV NIXSTATS_USERID="${NIXSTATS_USERID}"
RUN nixstatshello $NIXSTATS_USERID /etc/nixstats-token.ini
## RUN nohup bash -c "nixstatsagent &"
