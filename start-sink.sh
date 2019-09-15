#!/bin/bash

usage() { echo "Usage: $0 [-p <port>] [-n <portrange>]" 1>&2; exit 1; }

port=12340
portrange=16

while getopts ":p:n:" o; do
    case "${o}" in
        p)
            port=${OPTARG}
            ;;
        n)
            portrange=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

portrange_max=`expr ${portrange} - 1`

# xterm -geometry 50x2 -T "ncat sink port " -e "ncat -lk 1234 --max-conns 100 | pv -brt > /dev/null"
for i in $(seq 0 ${portrange_max})
do 
   this_port=`expr ${port} + ${i}`
   xterm -geometry 40x2 -T "ncat sink port ${this_port}" -e "ncat -lk ${this_port} --max-conns 100 | pv -brt > /dev/null" &
   echo  "ncat sink port ${this_port} started"
done

