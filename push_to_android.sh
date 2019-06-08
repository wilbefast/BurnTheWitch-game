#! /bin/bash

cd src
rm -f BurnTheWitch.love
zip -r BurnTheWitch.love ./
adb push BurnTheWitch.love /mnt/sdcard/BurnTheWitch.love