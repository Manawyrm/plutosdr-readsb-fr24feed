#!/bin/bash
while true; do
	/opt/fr24feed_armhf/fr24feed
	echo "fr24feed died! Restarting..."
	sleep 5
done

