#!/bin/bash
real_ip=$3
/bin/nc -vz $real_ip 54
named=$?

/bin/nc -vz $real_ip 8054
doh=$?

echo $named
echo $doh
if [[ $named == 0 ]] && [[ $named == 0 ]]; then
  exit 0
else
  exit 1
fi
