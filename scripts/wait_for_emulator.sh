#!/bin/bash

set +e

bootanim=""
failcounter=0
timeout_in_sec=60

until [[ "$bootanim" =~ "stopped" ]]; do
  bootanim=`adb -e shell getprop init.svc.bootanim 2>&1 &`
  if [[ "$bootanim" =~ "device not found" || "$bootanim" =~ "device offline" ]]; then
    let "failcounter += 1"
    echo "Waiting for emulator to start"
    if [[ $failcounter -gt timeout_in_sec ]]; then
      echo "Timeout ($timeout_in_sec seconds) reached; failed to start emulator"
      exit 1
    fi
  elif [[ "$bootanim" =~ "stopped" ]]; then
    echo "Emulator is ready"
    exit 0
  fi
  sleep 1
done

  # Check android device bridge, adb: http://developer.android.com/tools/help/adb.html
  # adb is a versatile command line tool that lets you communicate with an emulator.
  # adb -e: direct an adb command to the only running emulator. Return an error if more than one.
  # adb -d: direct an adb command to the only attached USB device. Return an error if more than one.
  # adb shell: starts a remote shell in a target emulator/device instance.
  # adb shell [shellCommand]: Issues a shell command in the target and then exits the remote shell.
  # adb shell getprop init.svc.bootanim: tell boot animation is running or not.
  # 2>&1: 2:stderr redirected to 1:stdout indicating 1 is a file descriptor and not a filename.
  # &: runs a command in the background, You can type other command while background job is running.
  # adb -e shell getprop init.svc.bootanim 2>&1 &: checks in the background if boot anim is running.

  # Check  http://stackoverflow.com/questions/19622198/what-does-set-e-in-a-bash-script-mean
  # Type help set in a terminal. Note: this no refers to the adb -e parameter. Refers to bash usage.
  # set -e  Exit immediately if a command exits with a non-zero status.
  # set -x  Print commands and their arguments as they are executed.
  # Using + rather than - causes these flags to be turned off.

  # Check device status: http://developer.android.com/tools/help/adb.html#devicestatus
  # adb devices: Prints a list of all attached emulator/device instances by serial number and state.
  # serial number: adb uniquely identify the target with the format <device/emulator>-<consolePort>.
  # Check command summary: http://developer.android.com/tools/help/adb.html#commandsummary
  # adb get-state: Prints the adb state of an emulator/device instance.
  # - no device: there is no emulator/device connected.
  # - offline: instance is not connected to adb or is not responding.
  # - device: instance is connected to the adb server but not implies fully booted and operational.
  # adb wait-for-device: blocks execution until the device is online (instance state is device).
  # adb start-server: checks whether the adb server process is running and starts it, if not.
  # adb stop-server: terminates the adb server process.
  # Check direct commands: http://developer.android.com/tools/help/adb.html#directingcommands
  # adb -s <serialNumber> <command>: send an adb command directly to a target when more than one.

  # Check new default/android-wait-for-emulator: https://github.com/travis-ci/travis-cookbooks ...
  # TODO: Test results. I think need fixes. Create my own script or oneline .travis.yml command.
  #
  # FATAL EXCEPTION IN SYSTEM PROCESS: main
  # E/AndroidRuntime(   87): java.lang.NullPointerException
  # E/AndroidRuntime(   87): 	at com.android.commands.input.Input.sendKeyEvent(Input.java:124) ...

  # Error states and what to do (based on values returned by init.svc.bootanim property):
  # - device not found: wait until emulator has been created and started or timeout reached.
  # - device offline: wait until emulator connected to adb or timeout reached,
  # - running: device is booting, connected to adb (device state). You can query it about state.
  # - stopped: ui appeared, it's safe to assume that emulator is running and ready to be used.
