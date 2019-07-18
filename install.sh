#!/bin/bash
if [ ! $# -eq 2 ]; then
	echo "Usage:"
	echo "  ./install.sh /sdcard/<source> <destination>"
	exit 1
fi

DEVICE=$(lsusb -v 2>/dev/null | grep 'Bus.*ID\|iInterface.*ADB Interface\|iSerial' | grep 'ADB Interface' -B 2)
if [ -z "$DEVICE" ]; then
	echo "No ADB device found" >&2
	exit 1
fi
ID=$(echo "$DEVICE" | awk 'NR==1{print $6}')
echo "Found ID: $ID"
SERIAL=$(echo "$DEVICE" | awk 'NR==2{print $3}')
echo "Found serial: $SERIAL"
if ! timeout 5 adb -s $SERIAL wait-for-device; then
	echo "Could not connect with ADB" >&2
	exit 1
fi

RULE="ACTION==\"add\", SUBSYSTEM==\"usb\", ATTR{idVendor}==\"${ID:0:4}\", ATTR{idProduct}==\"${ID:5:9}\", ATTR{serial}==\"$SERIAL\", ENV{DISPLAY}=\"$DISPLAY\", ENV{SERIAL}=\"$SERIAL\", ENV{SOURCE}=\"$1\", ENV{DEST}=\"$2\", RUN+=\"/bin/su $USER -c $PWD/sync.sh\""
sudo mkdir -p /etc/udev/rules.d &&
sudo bash -c "echo '$RULE' > /etc/udev/rules.d/85-$SERIAL.rules" &&
sudo udevadm control --reload &&
echo "Created udev rule: $RULE" &&
adb shell curl -o /sdcard/rsync.bin -L https://github.com/pts/rsyncbin/raw/master/rsync.rsync4android &&
adb shell 'exec >/sdcard/rsyncd.conf && echo address = 127.0.0.1 && echo port = 1873 && echo "[sdcard]" && echo path = /sdcard && echo use chroot = false && echo read only = true' &&
echo "Done"
