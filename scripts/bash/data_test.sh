#!/usr/bin/env bash
#This script gets a list of dates and uses arrays

date=`date +%Y-%m-%d`
avoid_days=("2018-05-07" "2018-05-14" "2018-06-05")

for i in ${avoid_days[@]}
do
   echo $i
done
