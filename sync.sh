#!/bin/bash
cd "$(dirname "$0")"
exec > $SERIAL.log
exec 2>&1

timeout 5 adb -s $SERIAL wait-for-device || exit 1
adb -s $SERIAL shell cp /sdcard/rsync.bin /data/local/tmp/rsync &&
adb -s $SERIAL shell chmod 755 /data/local/tmp/rsync &&
adb -s $SERIAL shell -x '/data/local/tmp/rsync --daemon --config=/sdcard/rsyncd.conf --log-file=/proc/self/fd/2'
adb -s $SERIAL forward tcp:6010 tcp:1873

# Wait for rsync daemon to be ready (10s timeout)
until rsync -n rsync://localhost:6010 > /dev/null || ((i++ >= 100)); do
  sleep .1
done

(
  rsync -rt  --progress --no-inc-recursive "rsync://localhost:6010$SOURCE" "$DEST" |
  awk -f rsync.awk |
  zenity --progress --title "Synchronizing files..." --time-remaining \
  --text="Scanning..." --percentage=0 --auto-close --auto-kill
  exit ${PIPESTATUS[0]}
)

if [ "$?" != 0 ]; then
  zenity --error --text="Synchronization failed or canceled" &
fi

adb -s $SERIAL shell pkill rsync
