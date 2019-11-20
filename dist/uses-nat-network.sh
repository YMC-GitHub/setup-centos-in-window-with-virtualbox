#!/bin/sh

##########
#use-nat-net-work
##########
# 通过cli的方式管理virtualbox 的nat 网络
# 需要：
# 新建一个网卡（叫网络也行）
# 虚机关联网卡

##########
# 新建一个网卡
##########
# 可以通过virtualbox的gui创建（gui）
# 可以通过virtualbox的cli创建（cli）
# 可以通过主机的控制面板-更改网络适配器进行创建（gui）
# ...
#网络名字
NAT_NETWORK_NAME=natnet1
#网络地址
NAT_NETWORK_ADDR=10.0.2.0 #10.0.x.0
#网络掩码
NAT_NETWORK_MASK=255.255.255.0
#网络前缀
NAT_NETWORK_PREFIX=24 #24
#动态获取
IS_DHCP=false
#网络操作
NAT_NETWORK_ACTION="create|start|list|use" #"create|start|stop|remove|update|list|use" #

#创建NAT网络
function add_natnetwork() {
  VBoxManage list natnetworks | grep -e "^NetworkName:" | sed "s/NetworkName: *//" | grep "${NAT_NETWORK_NAME}"
  if [ $? -eq 0 ]; then
    echo "has been created before" >/dev/null 2>&1
  else
    if [[ "$IS_DHCP" =~ 'false' ]]; then
      # 静态
      VBoxManage natnetwork add --netname $NAT_NETWORK_NAME --network "${NAT_NETWORK_ADDR}/${NAT_NETWORK_PREFIX}"
    else
      # 动态
      VBoxManage natnetwork add --netname $NAT_NETWORK_NAME --network "${NAT_NETWORK_ADDR}/${NAT_NETWORK_PREFIX}"
    fi
  fi

}
if [[ "$NAT_NETWORK_ACTION" =~ 'create' ]]; then
  add_natnetwork
fi

#开启NAT网络
if [[ "$NAT_NETWORK_ACTION" =~ 'start' ]]; then
  VBoxManage natnetwork start --netname $NAT_NETWORK_NAME
fi
#关闭NAT网络
if [[ "$NAT_NETWORK_ACTION" =~ 'stop' ]]; then
  VBoxManage natnetwork stop --netname $NAT_NETWORK_NAME
fi
#删除NAT网络
if [[ "$NAT_NETWORK_ACTION" =~ 'remove' ]]; then
  VBoxManage natnetwork remove --netname $NAT_NETWORK_NAME
fi
reference
