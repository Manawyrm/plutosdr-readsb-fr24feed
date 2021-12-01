#!/bin/bash

ip route add default via 192.168.2.1 || true

# Set the time & date
ntpdate ptbtime1.ptb.de

sleep 1

ntpdate ptbtime2.ptb.de

# Start the ADSB receiver
screen -dmS readsb /opt/readsb/readsb --device-type plutosdr --pluto-uri=local: --net --net-bo-port=30005 --gain=-10

# Give readsb some time to startup and start the TCP listener
sleep 5

# Start flightradar24 feeding daemon
screen -dmS fr24feed "/opt/fr24feed_armhf/fr24feed"
