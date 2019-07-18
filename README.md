## Automatically sync files over ADB using rsync when device is connected

### Installation

Connect device and run:

```
./install.sh /sdcard/<source> <destination>
```

**All files in the destination folder are deleted if they don't exists in the source folder. To prevent this, remove --delete in `sync.sh`**
