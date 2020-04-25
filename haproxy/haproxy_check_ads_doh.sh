#!/bin/bash
real_ip=$3
doh=$(/bin/nc -vz $real_ip 8054; echo $?)
named=$(/bin/nc -vz $real_ip 54; echo $?)
if [ $doh == "0" ] && [ $named == "0" ]; then
  exit 0
else
  exit 1
fi
