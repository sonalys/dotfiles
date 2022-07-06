#!/bin/sh

# Displays todays precipication chance (☔) and daily low (🥶) and high (🌞).
# Usually intended for the statusbar.

# If we have internet, get a weather report from wttr.in and store it locally.
# You could set up a shell alias to view the full file in a pager in the
# terminal if desired. This function will only be run once a day when needed.
weatherreport="${XDG_DATA_HOME:-$HOME/.local/share}/weatherreport"
getforecast() { curl -sf "wttr.in/$LOCATION" > "$weatherreport" || exit 1 ;}

# Some very particular and terse stream manipulation. We get the maximum
# precipitation chance and the daily high and low from the downloaded file and
# display them with coresponding emojis.
showweather() { 
	printf "🌧️ %s" "$(sed '16q;d' "$weatherreport" | grep -wo "[0-9]*%" | sort -rn | head -n 1 | tr -d '\n')"
	printf " 🌡️%s°" "$(sed 's/\x1B\[[0-9;]*[JKmsu]//g' $weatherreport | grep -Pwo "[0-9]+(?=.*C)" | head -n 1)"
	sed '13q;d' "$weatherreport" | grep -o "m\\([-+]\\)*[0-9]\\+" | sed 's/+//g' | sort -n -t 'm' -k 2n | sed -e 1b -e '$!d' | tr '\n|m' ' ' | awk '{print " 🥶" $1 "°","🌞" $2 "°C"}' ;
}

case $BLOCK_BUTTON in
	1) setsid -f "$TERMINAL" -e less -Srf "$weatherreport" ;;
	2) getforecast && showweather ;;
	6) "$TERMINAL" -e "$EDITOR" "$0" ;;
esac

# The test if our forcecast is updated to the day. If it isn't download a new
# weather report from wttr.in with the above function.
[ "$(stat -c %y "$weatherreport" 2>/dev/null | cut -d' ' -f1)" = "$(date '+%Y-%m-%d')" ] ||
	getforecast

showweather
