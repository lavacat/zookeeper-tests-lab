#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

runs=$1
threads=$2
maxmem=$3
cmd="ant clean test -Dtest.junit.threads=$threads -Dtest.junit.output.format=xml -Dtest.output=no -Dtest.junit.maxmem=$maxmem"
timestamp=$(date +%s)
log_dir=~/logs/$timestamp
zk_dir=~/zookeeper

echo "runs $runs, threads $threads maxmem $maxmem"
mkdir -p $log_dir
cd $zk_dir

branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
sha=$(git rev-parse HEAD)

for ((i = 1; i <= $runs; i++)); do
  echo "$(date +"%T.%3N") starting run $timestamp-$i on branch $branch sha $sha  with cmd \"$cmd\"" | tee $log_dir/$i-run.txt
  start=$(date +%s)
  eval "$cmd"  > $log_dir/$i-ant.txt 2>$1
  if (( $? )) ; then status="FAILED"; else status="OK"; fi
  end=$(date +%s)
  echo "$(date +"%T.%3N") result $status, took $((end-start)) sec" | tee $log_dir/$i-run.txt
  mv $zk_dir/build/test/logs $log_dir/$i-junit-logs

  #TODO: move to s3 bucket
done