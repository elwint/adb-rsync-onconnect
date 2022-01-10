## Automatically sync files with an Android device over ADB using rsync

### Prerequisites

* Rsync
* Zenity (remove zenity commands in `sync.sh` if you don't want to use zenity)

### Installation

**WARNING: All files in the destination folder are deleted if they don't exists in the source folder. To prevent this, remove `--delete` in `sync.sh`**

Connect device and run:

```
./install.sh /sdcard/<source> <destination>
```

E.g. `./install.sh /sdcard/DCIM/Camera/ ~/Pictures/Phone`

Every time the device is connected, `sync.sh` will be automatically executed to synchronize the files.

### Uninstallation

Remove the udev rule in `/etc/udev/rules.d/`
