#!/bin/bash

input=$1
case $input in
    start)
        nohup emacs &
        echo "started emacs"
        ;;
    stop)
        PID_string=$(ps aux | rg "\semacs" | gawk '{print $2}')
        PIDS=($PID_string)
        status=0
        for PID in "${PIDS[@]}"; do
            status=$(( $(kill -9 "$PID") + status))
        done
        if [ $status -eq 0 ]; then
            echo "killed all emacs"
        fi
        ;;
    *)
        echo "wrong input"
        ;;
esac
