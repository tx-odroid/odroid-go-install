#!/bin/bash

# ODROID GO install script macOS/Linux
# tx-odroid 9/2019

echo
echo Please disconnect ODROID GO if it is connected and hit RETURN
read

cd $(dirname $0)
. detect-os.rc

echo
echo detected OS: $OS_DETECTED
if [ "$OS_DETECTED" = "macos" ]
then
  echo "macOS detected: Please be sure that you have CP2104 VCP driver installed"
  echo "https://www.silabs.com/documents/public/software/Mac_OSX_VCP_Driver.zip"
fi

# defaults
SKETCHBOOK_PATH=~/Arduino
if [ "$OS_DETECTED" = "macos" ]
then
  SKETCHBOOK_PATH=~/Documents/Arduino
fi

# now check existing arduino prefs
export LATEST_ARDUINO_PREFS=$(ls -tr ~/Library/Arduino*/preferences.txt ~/.arduino*/preferences.txt 2>/dev/null|tail -n 1)
if [ "$LATEST_ARDUINO_PREFS" ]
then
  echo Found existing arduino prefs: $LATEST_ARDUINO_PREFS
  export SKETCHBOOK_PATH=$(grep sketchbook.path= "$LATEST_ARDUINO_PREFS"|tail -n 1|cut -d= -f2-)
  echo $SKETCHBOOK_PATH
else
  if [ "$OS_DETECTED" = "macos" ]
  then
    PREFS_DIR=~/Library/Arduino15
  else
    PREFS_DIR=~/.arduino15
  fi
  mkdir -p $PREFS_DIR
  LATEST_ARDUINO_PREFS=$PREFS_DIR/preferences.txt
fi

echo Setting board type in $LATEST_ARDUINO_PREFS
cat >>$LATEST_ARDUINO_PREFS <<EOF
sketchbook.path=$SKETCHBOOK_PATH
board=odroid_esp32
custom_DebugLevel=odroid_esp32_none
custom_FlashFreq=odroid_esp32_80
custom_FlashMode=odroid_esp32_qio
custom_PartitionScheme=odroid_esp32_default
custom_UploadSpeed=odroid_esp32_921600
target_package=espressif
target_platform=esp32
build.verbose=true
serial.port=/dev/odroid-go
serial.port.file=odroid-go
EOF

echo
echo "Using 'sudo' to install packages. On issues please use /bin/su to install group and packages."
sudo ./group-and-packages.sh $USER
[ "$?" = "111" ] && exit 111


echo
if [ "$OS_DETECTED" = "macos" ]
then
  if [ -d "/Applications/Arduino.app" ]
  then
    echo /Applications/Arduino.app found.
  else
    echo "No arduino found. Please install from https://www.arduino.cc/en/Main/Software"
    exit 1
  fi
else
  if type arduino &>/dev/null
  then
    echo arduino executable found.
  else
    echo "No arduino found. Please install via package manager or from https://www.arduino.cc/en/Main/Software"
    exit 1
  fi
fi

echo
echo Installing Arduino IDE for ESP32
mkdir -p "$SKETCHBOOK_PATH"/hardware/espressif
cd "$SKETCHBOOK_PATH"/hardware/espressif
mv esp32 esp32.old &>/dev/null
git clone --recursive https://github.com/espressif/arduino-esp32.git esp32 || exit 2
cd esp32/tools || exit 3
{ python get.py || python3 get.py; } || exit 4

echo
echo Installing ODROID-GO Libs
mkdir -p "$SKETCHBOOK_PATH"/libraries
cd "$SKETCHBOOK_PATH"/libraries
mv ODROID-GO ODROID-GO.old &>/dev/null
git clone https://github.com/hardkernel/ODROID-GO.git "$SKETCHBOOK_PATH"/libraries/ODROID-GO || exit 5

echo
echo Installing more software
mkdir -p "$SKETCHBOOK_PATH"
cd "$SKETCHBOOK_PATH"
rm -rf odroidgoupdater
git clone https://github.com/ripper121/odroidgoupdater.git 
rm -rf odroid-go-firmware
git clone https://github.com/OtherCrashOverride/odroid-go-firmware.git odroid-go-firmware
cd odroid-go-firmware/tools/mkfw || exit 6
make
cd "$SKETCHBOOK_PATH"
mkdir tools
cd tools
wget https://github.com/me-no-dev/arduino-esp32fs-plugin/releases/download/v0.1/ESP32FS-v0.1.zip
unzip ESP32FS-v0.1.zip

if [ -d /etc/udev/rules.d ]
then
  # faulty arduino can't handle the device symlinks as created by udev rule, do dirty workaround
  echo
  echo Please connect now your ODROID GO
  for f in {1..60}
  do
    sleep 1
    DEVICE=$(cd /dev;find * -maxdepth 0 -name "ttyUSB*" -mmin -1)
    if [ "$DEVICE" ]
    then
      echo Connected device: /dev/$DEVICE, adding to arduino prefs $LATEST_ARDUINO_PREFS
      echo serial.port=/dev/$DEVICE >>$LATEST_ARDUINO_PREFS
      echo serial.port.file=$DEVICE >>$LATEST_ARDUINO_PREFS
      echo
      break;
    fi
  done
fi

echo
  echo Starting arduino
if [ "$OS_DETECTED" = "macos" ]
then
  open /Applications/Arduino.app
else
  nohup arduino &>/dev/null &
fi

exit 0

# use modeline modelines=1 in vimrc
# vim: set sts=2 sw=2 ts=2 ai et:
