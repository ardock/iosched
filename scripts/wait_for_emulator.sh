#!/bin/bash

bootanim=""
failcounter=0
until [[ "$bootanim" =~ "stopped" ]]; do
   bootanim=`adb -e shell getprop init.svc.bootanim 2>&1`
   echo "$bootanim"
   if [[ "$bootanim" =~ "device not found" ]]; then
      let "failcounter += 1"
      if [[ $failcounter -gt 3 ]]; then
        echo "Failed to start emulator"
        exit 1
      fi
   fi
   sleep 1
done
echo "Done"

  # Check android device bridge, adb: http://developer.android.com/tools/help/adb.html
  # adb is a versatile command line tool that lets you communicate with an emulator.
  # adb -e: direct an adb command to the only running emulator. Return an error if more than one.
  # adb -d: direct an adb command to the only attached USB device. Return an error if more than one.
  # adb shell: starts a remote shell in a target emulator/device instance.
  # adb shell [shellCommand]: Issues a shell command in the target and then exits the remote shell.
  # adb shell getprop init.svc.bootanim: tell boot animation is running or not.
  # 2>&1: 2:stderr redirected to 1:stdout indicating 1 is a file descriptor (&) and not a filename.
  # &: runs a command in the background, You can type other command while background job is running.
  # adb -e shell getprop init.svc.bootanim 2>&1 &: checks in the background if boot anim is running.

  # Check  http://stackoverflow.com/questions/19622198/what-does-set-e-in-a-bash-script-mean
  # Type 'help set' in a terminal. Note: '-e' refers to bash usage no to adb -e parameter.
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

  # Error states and what to do (based on values returned by init.svc.bootanim property):
  # - device not found: wait until emulator has been created and started or timeout reached.
  # - device offline: wait until emulator connected to adb or timeout reached,
  # - running: device is booting, connected to adb (device state). You can query it about state.
  # - stopped: ui appeared, it's safe to assume that emulator is running and ready to be used.

  # Check new default/android-wait-for-emulator: https://github.com/travis-ci/travis-cookbooks ...
  # TODO: Test new script. I think need fixes. Create my own script or oneline .travis.yml command.
  # See issue: https://github.com/travis-ci/travis-ci/issues/2932
  # UPDATE: They solved the main problem but need optimize the loop without increase the failcounter
  # See Fix1: https://github.com/travis-ci/travis-cookbooks/pull/396
  # See Fix2: https://github.com/travis-ci/travis-cookbooks/pull/397

  # TODO: Support more than one emulator and test mobile and wearable together on travis servers.
  # Check http://developer.android.com/tools/help/adb.html#directingcommands
  # See issue, support more than one emulator: http://stackoverflow.com/questions/25330960/
  # See work in progress, serial property: https://code.google.com/p/android/issues/detail?id=75407
  # See work in progress, serial property: https://android-review.googlesource.com/#/c/108985/
  # See work in progress, renaming AVD: https://code.google.com/p/android/issues/detail?id=78677
  # See work in progress, renaming AVD: https://android-review.googlesource.com/#/c/113019/

  # TODO: error: protocol fault (no status). Use init.svc.bootanim 2>&1
