#!/bin/bash
pids=`ps ax | grep "dnscrypt-wrapper" | grep -v "grep" | grep -v "dnscrypt-daemon.sh" | awk '{ print $1 }'`
echo "Starting a new Wrapper"
/usr/local/etc/dnscrypt-wrapper/dnscrypt-wrapper.sh >/dev/null 2>&1
/usr/local/etc/dnscrypt-wrapper/ads-dnscrypt-wrapper.sh >/dev/null 2>&1
sleep 6
echo "Killing"
echo "$pids"
if [ "$pids" != "" ]; then
  for i in $pids; do
    echo "killing $i now"
    sudo kill -9 $i
  done
else
  echo "Done! Starting"
fi
