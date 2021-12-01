#!/bin/bash
while true; do
	/opt/readsb/readsb --device-type plutosdr --pluto-uri=local: --net --net-bo-port=30005 --gain=-10
        echo "readsb died! Restarting..."
        sleep 5
done
