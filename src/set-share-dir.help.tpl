
<desc>
  set share dir btween pm and vm
<desc/>
<args>
  -m,--machine options,set runing this shell on where
  --vm-name options,set the virtual machine name
  --pm-share-name options,set the share name
  --pm-share-dir options,set the share dir of pm
  --vm-mount-dir options,set the mount dir of vm
  -d,--debug options,set the debug mode
  -h,--help options,get the cmd help
<args/>
<how-to-run>
  run as shell args
    bash ./set-share-dir.sh
  run as runable application
    ./set-share-dir.sh --machine vm
<how-to-run/>
<demo-with-args>
  without args:
    ok:./set-share-dir.sh
  passed arg with necessary value:
    ok:./set-share-dir.sh --machine vm
  passed arg with optional value
  passed arg without value
<demo-with-args/>
<how-to-get-help>
  ok:./set-share-dir.sh --help
  ok:./set-share-dir.sh -h
debug-log:
<how-to-get-help/>
