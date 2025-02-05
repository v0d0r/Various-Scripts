#!/bin/bash

#Description:  This script can be scheduled via cron and will set all your microphone inputs to selected percentage because the annoying mac seems to change it randomly.
#Dependancies: This needs switchaudio to work. brew install switchaudio-osx
#Written by: Kevin Crous
#Last updated: 05/02/2025


# Check if user provided an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <volume_percentage>"
  echo "Example: $0 25 (sets all microphone volumes to 25%)"
  exit 1
fi

# Ensure the argument is a valid number between 0 and 100
if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 0 ] || [ "$1" -gt 100 ]; then
  echo "Error: Volume must be a number between 0 and 100."
  exit 1
fi

# Get all available input devices
mics=$(SwitchAudioSource -a -t input)

# Loop through each mic and set its volume
while IFS= read -r mic; do
  echo "Setting volume for: $mic"

  # Switch to the mic
  SwitchAudioSource -t input -s "$mic"

  # Set the input volume
  osascript -e "set volume input volume $1"

done <<< "$mics"

echo "All microphone input volumes set to $1%."

