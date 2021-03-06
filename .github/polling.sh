#!/bin/bash

declare -i duration=1
declare hasUrl=""
declare endpoint

usage() {
    cat <<END
    polling.sh [-i] [-h] endpoint
    
    Report the health status of the endpoint
    -i: include Uri for the format
    -h: help
END
}

while getopts "ih" opt; do 
  case $opt in 
    i)
      hasUrl=true
      ;;
    h) 
      usage
      exit 0
      ;;
    \?)
     echo "Unknown option: -${OPTARG}" >&2
     exit 1
     ;;
  esac
done

shift $((OPTIND -1))

if [[ $1 ]]; then
  endpoint=$1
else
  echo "Please specify the endpoint."
  usage
  exit 1 
fi 


healthcheck() {
    declare url=$1
    result=$(curl -i $url 2>/dev/null | grep -P HTTP\/\(\?\:2\|1.1\))
    echo $result
}

while [[ true ]]; do
   result=`healthcheck $endpoint` 
   declare status
   if [[ -z $result ]]; then 
      status="N/A"
   else
      status=${result:(-5)}
   fi 
   timestamp=$(date "+%Y%m%d-%H%M%S")
   if [[ -z $hasUrl ]]; then
     trap 'exit 0' 13
     echo "$timestamp | $status "
     trap 'exit 0' 13
   else
     echo "$timestamp | $status | $endpoint " 
   fi 
   sleep $duration
done