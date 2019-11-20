

<desc>
  uses hostonly network
<desc/>
<args>
  --vm-name options,set the virtual machine name
  --actions options,set the actions of net card operation,can be create|update|remove|list|use
  --id options,set the net card id,can be "|#2|#3|#x"
  -d,--debug options,set the debug mode
  -h,--help options,get the cmd help
<args/>
<how-to-run>
  run as shell args
    bash ./uses-hostonly-network.sh
  run as runable application
    ./uses-hostonly-network.sh --vm-name k8s-master
<how-to-run/>
<demo-with-args>
  without args:
    ok:./uses-hostonly-network.sh
  passed arg with necessary value:
    ok:./uses-hostonly-network.sh --vm-name k8s-master
  passed arg with optional value
  passed arg without value
<demo-with-args/>
<how-to-get-help>
  ok:./uses-hostonly-network.sh --help
  ok:./uses-hostonly-network.sh -h
  ok:./uses-hostonly-network.sh --debug
debug-log:
<how-to-get-help/>