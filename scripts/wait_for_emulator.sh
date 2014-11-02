#!/bin/bash

  # Check android device bridge, adb: http://developer.android.com/tools/help/adb.html
  # adb is a versatile command line tool that lets you communicate with an emulator.
  # adb -e: if only one device attached to adb, we can refer to it using this argument.
  # adb shell: starts a remote shell in a target emulator/device instance.
  # adb shell [shellCommand]: Issues a shell command in the target and then exits the remote shell.
  # adb shell getprop init.svc.bootanim: tell boot animation is running or not.
  # 2>&1: 2:stderr redirected to 1:stdout indicating 1 is a file descriptor and not a filename.
  # &: runs a command in the background, You can type other command while background job is running.
  # adb -e shell getprop init.svc.bootanim 2>&1 &: checks in the background if boot anim is running.

  # Check device status: http://developer.android.com/tools/help/adb.html#devicestatus
  # adb devices: Prints a list of all attached emulator/device instances by serial number and state.
  # serial number: adb uniquely identify the target with the format <device/emulator>-<consolePort>.
  # Check command summary: http://developer.android.com/tools/help/adb.html#commandsummary
  # adb get-state: Prints the adb state of an emulator/device instance.
  # - no device: there is no emulator/device connected.
  # - offline: instance is not connected to adb or is not responding.
  # - device: instance is connected to the adb server but not implies fully booted and operational.
  # Check direct commands: http://developer.android.com/tools/help/adb.html#directingcommands
  # adb -s <serialNumber> <command>: send an adb command directly to a target when more than one.

  # Check new default/android-wait-for-emulator: https://github.com/travis-ci/travis-cookbooks ...
  # Error states and what to do (based on values returned by init.svc.bootanim property):
  # - device not found: wait until emulator has been created and started or timeout reached.
  # - device offline: wait until emulator connected to adb or timeout reached,
  # - running: device is booting, connected to adb (device state). You can query it about state.
  # - stopped: ui appeared, it's safe to assume that emulator is running and ready to be used.

bootanim=""
failcounter=0
until [[ "$bootanim" =~ "stopped" ]]; do
  bootanim=`adb -e shell getprop init.svc.bootanim 2>&1`
  echo "$bootanim"
  if [[ "$bootanim" =~ "device not found" || "$bootanim" =~ "device offline" ]]; then
    let "failcounter += 1"
      if [[ $failcounter -gt 10 ]]; then
        echo "Failed to start emulator"
        exit 1
      fi
  elif [[ "$bootanim" =~ "running" ]]; then
    echo "Emulator is running but not ready"
  fi
  sleep 1
done
echo "Done"
