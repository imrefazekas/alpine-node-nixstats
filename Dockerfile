FROM mhart/alpine-node:latest

## OS related
RUN apk update && apk add --no-cache make gcc g++ git openssh wget nano python python-dev py-pip build-base linux-headers bash
RUN pip install --upgrade pip
RUN pip install nixstatsagent

## ENV NIXSTATS_USERID=INVALID
## RUN nixstatshello $NIXSTATS_USERID /etc/nixstats-token.ini
## RUN nohup bash -c "nixstatsagent &"
