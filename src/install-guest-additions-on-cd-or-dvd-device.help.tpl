<desc>
  install guest additions on cd or dvd device
<desc/>
<args>
  -m,--machine options,set runing this shell on where
  --vm-name options,set the virtual machine name
  --iso-file options,set the guest additions iso file
  -d,--debug options,set the debug mode
  -h,--help options,get the cmd help
<args/>
<how-to-run>
  run as shell args
    bash ./install-guest-additions-on-cd-or-dvd-device.sh
  run as runable application
    ./install-guest-additions-on-cd-or-dvd-device.sh --machine vm
<how-to-run/>
<demo-with-args>
  without args:
    ok:./install-guest-additions-on-cd-or-dvd-device.sh
  passed arg with necessary value:
    ok:./install-guest-additions-on-cd-or-dvd-device.sh --machine vm
  passed arg with optional value
  passed arg without value
<demo-with-args/>
<how-to-get-help>
  ok:./install-guest-additions-on-cd-or-dvd-device.sh --help
  ok:./install-guest-additions-on-cd-or-dvd-device.sh -h
debug-log:
<how-to-get-help/>
