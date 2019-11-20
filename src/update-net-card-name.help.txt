
<desc>
  update centos net card name
<desc/>
<args>
  --old-net-card-file-reg optional,set the old new card file name reg
  --new-net-card-name optional,set the new net card name
  --reboot optional,the switch to reboot machine
  -d,--debug optional,set the debug mode
  -h,--help optional,get the cmd help
<args/>
<how-to-run>
  run as shell args
    bash ./update-net-card-name.sh
  run as runable application
    ./update-net-card-name.sh --new-net-card-name eth0
<how-to-run/>
<demo-with-args>
  without args:
    ok:./update-net-card-name.sh
  passed arg with necessary value:
    ok:./update-net-card-name.sh --new-net-card-name eth0
  passed arg with optional value
  passed arg without value
<demo-with-args/>
<how-to-get-help>
  ok:./update-net-card-name.sh --help
  ok:./update-net-card-name.sh -h
debug-log:
<how-to-get-help/>
