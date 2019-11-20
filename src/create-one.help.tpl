
<desc>
  create a vm with virtualbox by VBoxManage cli
<desc/>
<args>
  -f,--file options,set the config file
  -h,--help options,get the cmd help
<args/>
<how-to-run>
  run as shell args
    bash ./create-one.sh
  run as runable application
    ./create-one.sh --file=vm-config.custom.txt
<how-to-run/>
<demo-with-args>
  without args:
    ok:./create-one.sh
  passed arg with necessary value:
    ok:./create-one.sh --file=vm-config.custom.txt
  passed arg with optional value
  passed arg without value
<demo-with-args/>
<how-to-get-help>
  ok:./create-one.sh --help
  ok:./create-one.sh -h
debug-log:
<how-to-get-help/>
