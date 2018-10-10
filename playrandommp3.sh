#!/bin/bash

# auther: kevin
# overview: pick random mp3 files from a folder and play with mpg123. using it for a halloween project to play random horror sounds based on motion to scare the begeezus out of the kids
# last modified: 10.10.2018
# dependencies: mpg123

selectmp3=$(ls /home/pi/sounds/ | shuf -n 1)
sourcefolder="/home/pi/sounds/"

/usr/bin/mpg123 "$sourcefolder""$selectmp3"

