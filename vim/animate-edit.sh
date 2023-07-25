#!/bin/bash
input="$1"
delay="0.1"  # Adjust this value to control the delay (in seconds)

# Read each line from the script file and simulate keypresses with delays
while read line; do
  echo -n $line
  sleep $delay
done < "$input"
