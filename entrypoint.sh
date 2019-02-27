#!/bin/bash

#For this to work set container hostname to be unique
SERVERID=$(hostname)

#Initialize nixstats
nixstatshello $NIXSTATS_USERID /etc/nixstats-token.ini $SERVERID

#Initialize logging config for nixstats
bash -c "/log-setup.sh"

#Start nixstats agent
nohup bash -c "nixstatsagent" &

#Start rsyslogd to send the logs
rsyslogd

#Start the main process defined in CMD
exec "$@" | tee >(logger -t "$NODE_ENV") 2>&1
