#!/bin/bash

job=48
# sinkserver='localhost'
sinkserver='192.168.82.45'

# xterm -geometry 50x2 -T "ncat sink port " -e "ncat -lk 1234 --max-conns 100 | pv -brt > /dev/null"
for zipcmd in lz4 lzop gzip
do     
    
    for ziplevel in 1 2 3 5 7 9
    do 
        echo "=========================================================================="
        echo ./start-compression.sh -j $job -z ${zipcmd} -l ${ziplevel} -s ${sinkserver}
        echo "=========================================================================="
        
        ./start-compression.sh -j $job -z ${zipcmd} -l ${ziplevel} -s ${sinkserver}
        
    done
    
done


