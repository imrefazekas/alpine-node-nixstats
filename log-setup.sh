#!/bin/bash

# Get the server ID from the nixstats config file to attach the logs to the specific server
NIXSTATS_SERVERID=$(tail -c 25 /etc/nixstats-token.ini)

# Change the values in the config
sed -i -e "s/SERVERTOKEN/$NIXSTATS_SERVERID/g" /etc/rsyslog.d/31-nixstats.conf
sed -i -e "s/USERTOKEN/$NIXSTATS_USERTOKEN/g" /etc/rsyslog.d/31-nixstats.conf
