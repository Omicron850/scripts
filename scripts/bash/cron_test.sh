#!/usr/bin/env bash
#This checks to see if you are on the last Monday of the month for a freeze period

weekday=`date +%A`
month_day=`date +%d`

 if [ $weekday == 'Monday' ] && [ $month_day -ge 21 ]
 then
        echo "Today is the last Monday of the month which is in the freeze period."
        exit 1
 fi
 start_date=`date +%m%d%y`
 num_days=31
 for i in `seq 0 $num_days`
 do
   date=`date +%Y-%m-%d -d "${start_date}+${i} days"`
   echo date
 done
