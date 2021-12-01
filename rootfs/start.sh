#!/bin/bash

dhclient -v eth0

# Set the time & date
ntpdate ptbtime1.ptb.de

sleep 1

ntpdate ptbtime2.ptb.de

# Start the ADSB receiver
screen -dmS readsb /start_readsb.sh

# Give readsb some time to startup and start the TCP listener
sleep 5

# Start flightradar24 feeding daemon
screen -dmS fr24feed /start_fr24feed.sh
