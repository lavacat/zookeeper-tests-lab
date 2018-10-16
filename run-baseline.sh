#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

runs=$1
threads=$2
maxmem=$3
timestamp=$(date +%s)
log_dir=~/logs/$timestamp
zk_dir=~/zookeeper

echo "runs $runs, threads $threads maxmem $maxmem"
mkdir -p $log_dir
cd $zk_dir

branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
sha=$(git rev-parse HEAD)


cmd() {
  echo "ant clean test -Dtest.junit.threads=$threads -Dtest.junit.output.format=xml -Dtest.output=no -Dtest.junit.maxmem=$maxmem" | tee -a $log_dir/$1-run.txt
  start=$(date +%s)
  ant clean test -Dtest.junit.threads=$threads -Dtest.junit.output.format=xml -Dtest.output=no -Dtest.junit.maxmem=$maxmem  > $log_dir/$1-ant.txt 2>&1
  if (( $? )) ; then status="FAILED"; else status="OK"; fi
  end=$(date +%s)
  echo "$(date +"%T.%3N") result $status, took $((end-start)) sec" | tee -a $log_dir/$1-run.txt
}

for ((i = 1; i <= $runs; i++)); do
  echo "$(date +"%T.%3N") starting run $timestamp-$i on branch $branch sha $sha" | tee -a $log_dir/$i-run.txt
  cmd $i
  mv $zk_dir/build/test/logs $log_dir/$i-junit-logs

  #TODO: move to s3 bucket
done