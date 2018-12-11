#!/bin/bash

# auther: kevin
# overview: a simple one liner to check what pid is using most open files cos i forget stuff now i git it"
# last modified: 11.12.2018
echo ""
echo "collecting lsof information and sorting by open files per pid"
echo "this will run a few seconds please wait....."
echo ""
lsof | awk '{print $2}' | sort | uniq -c | sort -n
echo "  ----------"
echo "  Files  PID"
echo "  ----------"
