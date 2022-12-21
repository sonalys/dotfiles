#!/bin/bash
SINKS=$(pactl list short sinks)
SINK_COUNT=$(echo "$SINKS" | wc -l)
CURR_SINK=$(echo "$SINKS" | grep -Po "([0-9]).*(?<=RUNNING)")
CURR_SINK_ID=$(echo $CURR_SINK | cut -d ' ' -f 1)
NEXT_SINK_ID=$(( ($CURR_SINK_ID + 1) % $SINK_COUNT ))
pactl set-default-sink $NEXT_SINK_ID
