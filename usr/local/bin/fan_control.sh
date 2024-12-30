#!/bin/sh
set -euo pipefail
export LC_NUMERIC="C"

FAN_ON_TEMP=60.0
FAN_OFF_TEMP=50.0
FAN_PIN=18

LOG_FILE="/var/log/fan_control.log"
LOG_INFO="INFO"
LOG_ERROR="ERROR"
LOG_WARN="WARNING"
ON=1
OFF=0

FAN_STATE=0

get_date() {
    date "+%Y.%m.%d %H:%M:%S"
}

log_message() {
    level=$1
    message=$2
    echo "$(get_date) [${level}] ${message}" >> $LOG_FILE
}

set_fan_state() {
    FAN_STATE=$1
    gpioctl $FAN_PIN $FAN_STATE
}

cleanup() {
    log_message $LOG_INFO "Shutting down fan control..."
    set_fan_state $OFF
    exit 0
}

trap cleanup EXIT SIGTERM SIGINT

gpioctl -c $FAN_PIN out
set_fan_state $OFF

touch $LOG_FILE
log_message $LOG_INFO "Fan control service started"

while true; do
   CPU_TEMP=$(sysctl -n dev.cpu.0.temperature | tr -d 'C') 

   if echo "$CPU_TEMP >= $FAN_ON_TEMP" | bc -l | grep -q 1; then
      if [ $FAN_STATE -eq $OFF ]; then
         set_fan_state $ON
         log_message $LOG_INFO "Fan turned ON - CPU temperature: ${CPU_TEMP}°C"
         sleep 5
      fi
   elif echo "$CPU_TEMP < $FAN_OFF_TEMP" | bc -l | grep -q 1; then
      if [ $FAN_STATE -eq $ON ]; then
        set_fan_state $OFF
        log_message $LOG_INFO "Fan turned OFF - CPU temperature: ${CPU_TEMP}°C"
      fi
   fi
   sleep 5
done

