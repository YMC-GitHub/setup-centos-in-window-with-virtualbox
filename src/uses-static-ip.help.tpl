<desc>
  uses static ip for a machine
<desc/>
<args>
  --net-card-name optional,set the vm net card name
  --vm-ipaddr optional,set the vm ip addr
  --vm-gateway optional,set the vm gateway
  --vm-netmask optional,set the vm net mask
  --action optional,set the action as set or revocer
  --restart-network optional,swicth the network restart
  -h,--help optional,get the cmd help
<args/>
<how-to-run>
  run as shell args
    bash ./uses-static-ip.sh
  run as runable application
    ./uses-static-ip.sh --net-card-name eth0
<how-to-run/>
<demo-with-args>
  without args:
    ok:./uses-static-ip.sh
  passed arg with necessary value:
    ok:./uses-static-ip.sh --net-card-name eth0
  passed arg with optional value
  passed arg without value
<demo-with-args/>
<how-to-get-help>
  ok:./uses-static-ip.sh --help
  ok:./uses-static-ip.sh -h
  ok:./uses-static-ip.sh --debug
<how-to-get-help/>
