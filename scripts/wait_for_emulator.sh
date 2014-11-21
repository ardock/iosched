#!/bin/bash

bootanim=""
failcounter=0
until [[ "$bootanim" =~ "stopped" ]]; do
   bootanim=`adb -e shell getprop init.svc.bootanim 2>&1`
   echo "$bootanim"
   if [[ "$bootanim" =~ "device not found" ]]; then
      let "failcounter += 1"
      if [[ $failcounter -gt 15 ]]; then
        echo "Failed to start emulator"
        exit 1
      fi
   fi
   sleep 1
done
echo "Done"


  # TODO: Optimize wait_for_emulator script. (Added "device " to "not found" string as a quick fix).
  # Check android device bridge, adb: http://developer.android.com/tools/help/adb.html
  # adb is a versatile command line tool that lets you communicate with an emulator.
  # adb -e: direct an adb command to the only running emulator. Return an error if more than one.
  # adb -d: direct an adb command to the only attached USB device. Return an error if more than one.
  # adb shell: starts a remote shell in a target emulator/device instance.
  # adb shell [shellCommand]: Issues a shell command in the target and then exits the remote shell.
  # adb shell getprop init.svc.bootanim: tell boot animation is running or not.
  # `adb -e shell getprop init.svc.bootanim 2>&1`: checks in a subshell if boot anim is running.

  # Backticks (`) runs the command in a subshell and returns the standard output from that command,
  # we only get the standard output (stdout) but we do not get the standard error (stderr).
  # Use 2>&1, so errors as 'protocol fault (no status)' are redirected to stdout.
  # 2>&1: 2:stderr redirected to 1:stdout indicating 1 is a file descriptor '&1' and not a filename.

  # Check device status: http://developer.android.com/tools/help/adb.html#devicestatus
  # adb devices: Prints a list of all attached emulator/device instances by serial number and state.
  # serial number: adb uniquely identify the target with the format <device/emulator>-<consolePort>.
  # adb get-state: Prints the adb state of an emulator/device instance:
  # - no device: there is no emulator/device connected.
  # - offline: instance is not connected to adb or is not responding.
  # - device: instance is connected to the adb server but not implies fully booted and operational.

  # Error states and what to do (based on values returned by init.svc.bootanim property):
  # - device not found: wait until emulator has been created and started or timeout reached.
  # - device offline: wait until emulator connected to adb or timeout reached,
  # - running: device is booting, connected to adb (device state). You can query it about state.
  # - stopped: ui appeared, it's safe to assume that emulator is running and ready to be used.

  #

  # TODO: Test new default script. Currently needs fixes. Create a new script or travis.yml command.
  # Check new default/android-wait-for-emulator: https://github.com/travis-ci/travis-cookbooks ...
  # See issue 1, new default needs be fixed: https://github.com/travis-ci/travis-ci/issues/2932
  # See Fix 1: https://github.com/travis-ci/travis-cookbooks/pull/396
  # UPDATE: They solved the main problem but need optimize the loop without increase the failcounter
  # See issue 2, emulator loading slow: https://code.google.com/p/android/issues/detail?id=77283
  # See Fix 2: https://github.com/travis-ci/travis-cookbooks/pull/397

  # Check  http://stackoverflow.com/questions/19622198/what-does-set-e-in-a-bash-script-mean
  # Type 'help set' in a terminal. Note: '-e' refers to bash usage no to adb -e parameter.
  # set -e  Exit immediately if a command exits with a non-zero status.
  # set -x  Print commands and their arguments as they are executed.
  # Using + rather than - causes these flags to be turned off.

  # &: runs a command in the background, You can type other command while background job is running.
  # adb -e shell getprop init.svc.bootanim 2>&1 &: checks in the background if boot anim is running.

  #

  # TODO: Support more than one emulator simultaneously (test mobile and wearable at the same time).
  # See issue, support more than one emulator: http://stackoverflow.com/questions/25330960/
  # See work in progress, serial property: https://code.google.com/p/android/issues/detail?id=75407
  # See work in progress, serial property: https://android-review.googlesource.com/#/c/108985/
  # See work in progress, renaming AVD: https://code.google.com/p/android/issues/detail?id=78677
  # See work in progress, renaming AVD: https://android-review.googlesource.com/#/c/113019/

  # Check command summary: http://developer.android.com/tools/help/adb.html#commandsummary
  # adb wait-for-device: blocks execution until the device is online (instance state is device).
  # adb start-server: checks whether the adb server process is running and starts it, if not.
  # adb stop-server: terminates the adb server process.
  # Check direct commands: http://developer.android.com/tools/help/adb.html#directingcommands
  # adb -s <serialNumber> <command>: send an adb command directly to a target when more than one.
