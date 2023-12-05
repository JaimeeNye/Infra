#!/bin/sh
while true ; do
    python3 /home/pi/waker.py 'localhost' "{{ waker_pc_mac_address }}" "{{ mosquitto_user }}" "{{ mosquitto_password }}"
done
