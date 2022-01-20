#!/bin/bash

# You can call this script like this:
# $./volume.sh up
# $./volume.sh down
# $./volume.sh mute

function get_volume {
    pactl list sinks | grep -i volume | head -1 | awk '{print $5}' | sed -e 's/%//'
}

function is_mute {
    amixer get Master | grep '%' | grep -oE '[^ ]+$' | grep off > /dev/null
}

function send_notification {
    volume=`get_volume`
    # Make the bar with the special character ─ (it's not dash -)
    # https://en.wikipedia.org/wiki/Box-drawing_character
    bar=$(seq -s "─" $(($volume / 5)) | sed 's/[0-9]//g')
    # Send the notification
    dunstify -i audio-volume-muted-blocking -r 2593 \
	    -h int:value:$volume \
	    -h string:bgcolor:"#343434" \
	    -h string:hlcolor:"#e44138" \
	    "Volume"
}

case $1 in
    up)
	# Set the volume on (if it was muted)
	pactl set-sink-mute @DEFAULT_SINK@ 0
	# Up the volume (+ 5%)
	pactl set-sink-volume @DEFAULT_SINK@ +10%
	send_notification
	;;
    down)
	pactl set-sink-volume @DEFAULT_SINK@ -10%
	send_notification
	;;
    mute)
    	# Toggle mute
	pactl set-sink-mute @DEFAULT_SINK@ toggle
	if is_mute ; then
	    dunstify -i audio-volume-muted -t 8 -r 2593 -u normal "Mute"
	else
	    send_notification
	fi
	;;
esac
