#!/bin/bash

INSTALL_USER=$1

. detect-os.rc

if [ "$OS_DETECTED" = "macos" ]
then
  #echo 'macOS detected. Creating symlink /dev/odroid-go => /dev/cu.SLAB_USBtoUART'
  #ln -s cu.SLAB_USBtoUART /dev/odroid-go
  if [ "$MACOS_PACKAGER" = "port" ]
  then
    port install py37-pip ffmpeg && exit 0
    #pip3 install esptool
  else
    echo Please add brew command to install pip and ffmpeg
    exit 0
  fi
  exit 10
fi

# only Linux

# groups
usermod -a -G dialout $INSTALL_USER
usermod -a -G lock $INSTALL_USER 2>/dev/null
if grep -q dialout /etc/group
then
  # unlikely
  id $INSTALL_USER -G -n|tr ' ' '\n'|grep -q '^dialout$' || { echo "Not member of group dialout. Please re-login and start again."; exit 111; }
fi


if [ -d /etc/udev/rules.d ]
then
  echo
  echo udev rules dir detected, installing rule for /dev/odroid-go
  umask 022
  echo '# ODROID GO (Silicon Labs CP2104)
SUBSYSTEM=="usb", ATTR{idVendor}=="10c4", ATTR{idProduct}=="ea60", GROUP="dialout", MODE="0664", SYMLINK+="odroid-go"' >/etc/udev/rules.d/94-odroid-go.rules
fi

echo

if [ "$OS_DETECTED" = "debian" ]
then
  if [ $(python --version 2>&1 | grep '2.7' | wc -l) = "1" ]
  then
    apt-get install python-pip python-pyserial
  else
    apt-get install python3-pip python3-pyserial
  fi
  apt-get install git && exit 0
  exit 10
fi

if [ "$OS_DETECTED" = "fedora" ]
then
  # return code will be ignored, check will be done later
  dnf install arduino arduino-builder arduino-listSerialPortsC arduino-ctags
  # this one according to espressif:
  dnf install git wget ncurses-devel flex bison gperf python pyserial python-pyelftools cmake ninja-build ccache
  # for odroid-go:
  dnf install git python3-pip python3-pyserial ffmpeg && exit 0
  exit 10
fi

if [ "$OS_DETECTED" = "centos" ]
then
  # this one according to espressif:
  yum install git wget ncurses-devel flex bison gperf python pyserial python-pyelftools cmake ninja-build ccache
  # for odroid-go:
  yum install git python3-pip python3-pyserial && exit 0
  exit 10
fi

if [ "$OS_DETECTED" = "suse" ]
then
  if [ $(python --version 2>&1 | grep '2.7' | wc -l) = "1" ]
  then
    zypper install git python-pip python-pyserial && exit 0
  else
    zypper install git python3-pip python3-pyserial && exit 0
  fi
  exit 10
fi

exit 0

# use modeline modelines=1 in vimrc
# vim: set sts=2 sw=2 ts=2 ai et:
