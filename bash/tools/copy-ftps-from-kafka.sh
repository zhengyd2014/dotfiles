#!/usr/bin/env bash

namespace=$1

kafka_log_dir='/mnt/data/data0/logs'
kubectl_cmd="kubectl -n $namespace"
pods=$($kubectl_cmd get pods | grep kafka | grep -v healthcheck | awk '{print $1}')

for pod in $pods
do
    echo "==== copying ftps files from $pod ===="
    ftps_files=$($kubectl_cmd exec -ti $pod -- find $kafka_log_dir | grep 00000000000000000000.tierstate.adler)
    echo $ftps_files
    # count=0
    # # for file in $ftps_files
    # # do
    # #     count=$((count + 1))
    # #     echo "--- copy $file from $pod to local ---"
    # # done
    # echo "copied $count ftps file"
done

function cp_ftps_from_pod() {
    pod=$1

    echo "working on $pod"
    
}