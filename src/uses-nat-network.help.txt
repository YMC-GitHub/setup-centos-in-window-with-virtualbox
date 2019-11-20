<desc>
  uses nat network
<desc/>
<args>
  --vm-name optional,set the virtual machine name
  --net-card-number optional,set the vm net card id
  -d,--debug optional,set the debug mode
  -h,--help optional,get the cmd help
<args/>
<how-to-run>
  run as shell args
    bash ./uses-nat-network.sh
  run as runable application
    ./uses-nat-network.sh --vm-name k8s-master
<how-to-run/>
<demo-with-args>
  without args:
    ok:./uses-nat-network.sh
  passed arg with necessary value:
    ok:./uses-nat-network.sh --vm-name k8s-master
  passed arg with optional value
  passed arg without value
<demo-with-args/>
<how-to-get-help>
  ok:./uses-nat-network.sh --help
  ok:./uses-nat-network.sh -h
  ok:./uses-nat-network.sh --debug
debug-log:
<how-to-get-help/>
