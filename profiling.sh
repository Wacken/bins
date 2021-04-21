#!/usr/bin/env bash

exec 3>&2 2> >( tee /tmp/sample-$$.log |
                  sed -u 's/^.*$/now/' |
                  date -f - +%s.%N >/tmp/sample-$$.tim)
set -x

for ((i=3;i--;));do sleep .1;done

for ((i=2;i--;))
do
    tar -cf /tmp/test.tar -C / bin
    gzip /tmp/test.tar
    rm /tmp/test.tar.gz
done

set +x
exec 2>&3 3>&-

# paste <(
#     while read tim ;do
#         crt=000000000$((${tim//.}-10#0$last))
#         printf "%12.9f\n" ${crt:0:${#crt}-9}.${crt:${#crt}-9}
#         last=${tim//.}
#       done < sample-2336185.tim
#   ) sample-2336185.log

# restricted usage of strace
# strace -f -s 10 -r -eopen,access,read,write Files/shell-scripts/profiling.sh 2>strace.log

# for simple timing use time
