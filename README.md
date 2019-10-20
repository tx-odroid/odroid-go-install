# odroid-go-install
Script based install of ODROID GO development environment for Linux or macOS

The scripts are based on the tutorial
[Getting started with Arduino](https://wiki.odroid.com/odroid_go/arduino/01_arduino_setup)
in ODROID Wiki.
Additional software like e.g.
[OtherCrashOverride/odroid-go-firmware](https://github.com/OtherCrashOverride/odroid-go-firmware)
is also installed.

odroid-go-install is tested on macOS (with ports) and Fedora.

## Requirements

   * Arduino IDE already installed
   * git (of course)
   * POSIX environment because of Linux and macOS (Windows with e.g. git shell is not tested)

## Installation

Your Arduino IDE must not run while installation.

    $ cd odroid-go-install
    $ ./INSTALL.sh

Installation will be done in ~/Arduino (Linux) or ~/Documents/Arduino (macOS).
A basic Arduino configuration will be created in ~/Library/Arduino15/ (macOS)
or ~/.arduino15/ (Linux). The device will be pre-selected for ODROID GO (odroid\_esp32).

