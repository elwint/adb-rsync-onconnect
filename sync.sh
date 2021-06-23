#!/bin/bash
cd "$(dirname "$0")"
exec > $SERIAL.log
exec 2>&1

timeout 5 adb -s $SERIAL wait-for-device || exit 1
adb -s $SERIAL shell cp /sdcard/rsync.bin /data/local/tmp/rsync &&
adb -s $SERIAL shell chmod 755 /data/local/tmp/rsync &&
adb -s $SERIAL shell -x '/data/local/tmp/rsync --daemon --no-detach --config=/sdcard/rsyncd.conf --log-file=/proc/self/fd/2' &
adb -s $SERIAL shell 'until pidof rsync > /dev/null; do sleep .1; done'
adb -s $SERIAL forward tcp:6010 tcp:1873

rsync -rt --delete --progress --no-inc-recursive "rsync://localhost:6010$SOURCE" "$DEST" |
	awk -f rsync.awk |
	zenity --progress --title "Synchronizing files..." --time-remaining \
		--text="Scanning..." --percentage=0 --auto-close &

PID=$!
until [ -z "$PID" ]; do
	PID=$(ps h -o pid --pid $PID | xargs)
	sleep .1
done

adb -s $SERIAL shell killall rsync
wait $!
if [ "$?" = 1 ]; then
	zenity --error --text="Synchronization cancelled"
fi
