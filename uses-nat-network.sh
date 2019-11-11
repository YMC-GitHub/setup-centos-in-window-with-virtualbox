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
function add_natnetwork(){
VBoxManage list natnetworks | grep -e "^NetworkName:" | sed "s/NetworkName: *//" | grep "${NAT_NETWORK_NAME}"
if [ $? -eq 0 ]
then
    echo "has been created before" > /dev/null 2>&1
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
#更新NAT网络
#2 创建某一端口转换规则
#规则名字
RULE_NAME=ssh
#物机端口
PM_PORT=22
#传输协议
RULE_PROTO=tcp
#虚机端口
VM_PORT=22
#虚机地址
VM_ADDR=192.168.2.3
#3 从物理主机的$PM_PORT端口$RULE_PROTO到IP地址为$VM_ADDR的虚拟机$VM_PORT端口。物理主机端口、虚拟机端口、虚拟机IP
#VBoxManage natnetwork modify --netname $NAT_NETWORK_NAME --port-forward-4 "${RULE_NAME}:${RULE_PROTO}:[]:${PM_PORT}:[${VM_ADDR}]:${VM_PORT}" 
#2 删除某一端口转换规则
#VBoxManage natnetwork modify --netname $NAT_NETWORK_NAME --port-forward-4 delete $RULE_NAME 
#2
#VBoxManage natnetwork modify --netname $NAT_NETWORK_NAME --dhcp on
#2
#VBoxManage natnetwork modify --netname $NAT_NETWORK_NAME --network <network>
#2
#VBoxManage natnetwork modify --netname $NAT_NETWORK_NAME --ipv6 on
#2
#VBoxManage natnetwork modify --netname $NAT_NETWORK_NAME --port-forward-6 <rule>
#2

#列出NAT网络
if [[ "$NAT_NETWORK_ACTION" =~ 'list' ]]; then
    VBoxManage list natnetworks
    #
    #VBoxManage list natnets
fi

#使用NAT网络
# 虚拟主机名字
VM_NAME=centos-7.6-clone
# 网卡序号
NET_CARD_NUMBER=2
# 网络类型
NET_WORK_TYPE=nat #--nic<1-N> none|null|nat|natnetwork|bridged|intnet|hostonly|generic
#
NET_WORK_DEVICE_TYPE=82540EM #--nictype<1-N> Am79C970A|Am79C973|82540EM|82543GC|82545EM|virtio:
# --nat-network<1-N> <network name>:
#使用
#2 动态获取IP地址
#VBoxManage modifyvm $VM_NAME --natpf2 "guestssh,tcp,,2222,,22"
#2 静态获取IP地址
#VBoxManage modifyvm $VM_NAME --natpf2 "guestssh,tcp,,2222,10.0.2.19,22"
#VBoxManage modifyvm $VM_NAME --nat-network<1-N> $NAT_NETWORK_NAME
#VBoxManage modifyvm $VM_NAME --nic2 nat --nictype2 82540EM --cableconnected2 on
if [[ "$NAT_NETWORK_ACTION" =~ 'use' ]]; then
VBoxManage list runningvms | sed "s#{.*}##g" | grep $VM_NAME
# 关闭
if [ $? -eq 0 ];then
    VBoxManage controlvm $VM_NAME poweroff
    sleep 5
fi
fi

if [ $NET_WORK_TYPE = "nat" ]
then
    # the next line can not clean clearly
    $(VBoxManage modifyvm $VM_NAME --nic${NET_CARD_NUMBER} none)
    $(VBoxManage modifyvm $VM_NAME --nic${NET_CARD_NUMBER} nat)
elif [ $NET_WORK_TYPE = "natnetwork" ]
then
    $(VBoxManage modifyvm $VM_NAME --nic${NET_CARD_NUMBER} none)
    # the next line can not work!
    #$(VBoxManage modifyvm $VM_NAME --natnet$NET_CARD_NUMBER $NAT_NETWORK_NAME --nic$NET_CARD_NUMBER natnetwork --nictype$NET_CARD_NUMBER $NET_WORK_DEVICE_TYPE --cableconnected$NET_CARD_NUMBER on)
    # the next line can not work!
    #$(VBoxManage modifyvm $VM_NAME --nat-network$NET_CARD_NUMBER $NAT_NETWORK_NAME --nic$NET_CARD_NUMBER natnetwork --nictype$NET_CARD_NUMBER $NET_WORK_DEVICE_TYPE --cableconnected$NET_CARD_NUMBER on)
    #https://www.virtualbox.org/manual/UserManual.html#changenat
fi
# you can update the natnet network with below:
#VBoxManage modifyvm $VM_NAME --natnet$NET_CARD_NUMBER "10.0.2.0/24"
#VBoxManage modifyvm $VM_NAME --natnet$NET_CARD_NUMBER "192.168.x.0/24"
#VBoxManage modifyvm $VM_NAME --natnet$NET_CARD_NUMBER "xxx.xxx.x.0/xx"
#
#### 参考文献
:<<reference
VirtualBox 网络连接方式研究（一）
https://www.iteye.com/blog/815222418-2313338
VirtualBox配置固定IP和联网（gui）(Host-only+nat)
https://blog.csdn.net/wang5990302/article/details/80282322
virtualbox 虚拟机静态IP设置（用于Host Only和NAT共存的方式）
https://blog.csdn.net/ztchun/article/details/73195487
virtualbox centos 使用NAT模式上网（gui）
https://blog.csdn.net/baidu_3
1945865/article/details/88360830
Control Panel\Network and Internet\Network Connections(gui)

Virtualbox桥接实现静态固定IP内外网访问
https://blog.csdn.net/qq_25166683/article/details/83211617

子网划分详解与子网划分实例精析
https://blog.csdn.net/gui951753/article/details/79412524

reference