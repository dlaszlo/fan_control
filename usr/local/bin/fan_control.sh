#!/bin/sh
set -e

FAN_ON_TEMP=60
FAN_OFF_TEMP=50
FAN_PIN=18
FAN_STATE=0

LOG_FILE="/var/log/fan_control.log"
LOG_INFO="INFO"
LOG_ERROR="ERROR"
LOG_WARN="WARNING"

get_date() {
    date "+%Y.%m.%d %H:%M:%S"
}

log_message() {
    level=$1
    message=$2
    echo "$(get_date) [${level}] ${message}" >> $LOG_FILE
}

cleanup() {
    log_message $LOG_INFO "Shutting down fan control..."
    gpioctl $FAN_PIN 0  # Turn off fan
    exit 0
}

trap cleanup SIGTERM SIGINT

gpioctl -c $FAN_PIN out
gpioctl $FAN_PIN 0

touch $LOG_FILE
log_message $LOG_INFO "Fan control service started"

while true; do
   CPU_TEMP=$(sysctl -n dev.cpu.0.temperature | cut -d '.' -f1) || {
        log_message $LOG_ERROR "Failed to read CPU temperature"
        sleep 5
        continue
   }
   if [ $CPU_TEMP -ge $FAN_ON_TEMP ] && [ $FAN_STATE -eq 0 ]; then
      FAN_STATE=1
      gpioctl $FAN_PIN $FAN_STATE
      log_message $LOG_INFO "Fan turned ON - CPU temperature: ${CPU_TEMP}°C"
      sleep 5
   elif [ $CPU_TEMP -lt $FAN_OFF_TEMP ] && [ $FAN_STATE -eq 1 ]; then
      FAN_STATE=0
      gpioctl $FAN_PIN $FAN_STATE
      log_message $LOG_INFO "Fan turned OFF - CPU temperature: ${CPU_TEMP}°C"
   fi
   sleep 5
done

