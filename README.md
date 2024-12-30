# Fan Control Service for FreeBSD on Raspberry PI

This project consists of two scripts that together provide automatic fan control based on CPU temperature on Raspberry Pi running FreeBSD. The fan is controlled via a GPIO pin and will turn on or off depending on the CPU temperature. The fan control script runs as a service, and you can enable it to start on boot.

## Requirements

- FreeBSD system with GPIO control enabled.
- A fan connected to a GPIO pin (default: pin 18).
- `gpioctl` command to control the GPIO pins.

## Configuration

- `FAN_ON_TEMP`: The temperature (in Celsius) at which the fan will turn on. Default: `60°C`.
- `FAN_OFF_TEMP`: The temperature (in Celsius) at which the fan will turn off. Default: `50°C`.
- `FAN_PIN`: The GPIO pin number connected to the fan. Default: `18`.
- `LOG_FILE`: The file to store log messages. Default: `/var/log/fan_control.log`.

## Usage

1. **Fan Control Script**: This script controls the fan based on CPU temperature.  
   Copy the script to `/usr/local/bin/fan_control.sh` and make it executable:
   ```sh
   chmod +x /usr/local/bin/fan_control.sh
   ```
2. **Service Script**: This script integrates with FreeBSD's service management system (rc.d).
   It allows the fan control script to be managed as a service.
   Copy the service script to `/usr/local/etc/rc.d/fan_control` and make it executable:
   ```sh
   chmod +x /usr/local/etc/rc.d/fan_control
   ```
3. ***Enable the Service***:
   Add the following line to /etc/rc.conf to enable the fan control service:
   ```sh
   fan_control_enable="YES"
   ```
4. ***Start the Service***:
   Start the fan control service with the following command:
   ```sh
   service fan_control start
   ```
   To stop the service:
    ```sh
    service fan_control stop
    ```

The fan control script will check the CPU temperature every 5 seconds to turn the fan on, 
and every 10 seconds to turn it off. It will also log actions to the specified log file.      

