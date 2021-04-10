#!/bin/bash

date1="Jan 1, 2020"
date2="Mar 22, 2020"
time1=$(date -d "$date1" +%s)
time2=$(date -d "$date2" +%s)
diff=$(expr $time2 - $time1)
secondinday=$(expr 24 \* 60 \* 60)
days=$(expr $diff / $secondinday)
echo "the difference between $date1 and $date2 is $days days"
