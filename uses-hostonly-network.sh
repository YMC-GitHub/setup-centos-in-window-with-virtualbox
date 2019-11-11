#!/bin/sh

# 使用hostonly
# 需要：
# 创建hostonly网卡
# 使用hostonly网卡

# 网卡名字前缀
INTERNAL_NET_WORK_NAME_PREFIX="VirtualBox Host-Only Ethernet Adapter"
#INTERNAL_NET_WORK_NAME_ID="" # "#2|"
# 网卡名字编号
INTERNAL_NET_WORK_NAME_ID="#2"
# 网卡名字
INTERNAL_NET_WORK_NAME=
# 网络地址
NET_WORK_IP=192.168.3.1
# 网络掩码
NET_WORK_MASK=255.255.255
# 网卡操作
NET_CARD_ACTION="create|list|use" #"create|update|remove|list"

# 生成网卡名字
if [ -n $INTERNAL_NET_WORK_NAME_ID ]
then
    INTERNAL_NET_WORK_NAME="$INTERNAL_NET_WORK_NAME_PREFIX $INTERNAL_NET_WORK_NAME_ID"
else
    INTERNAL_NET_WORK_NAME=$INTERNAL_NET_WORK_NAME_PREFIX
fi
echo $INTERNAL_NET_WORK_NAME

#创建hostonly网卡
if [[ "$NET_CARD_ACTION" =~ 'create' ]]; then
VBoxManage list hostonlyifs | grep -e "^Name:" | sed "s/Name: *//" | grep "${INTERNAL_NET_WORK_NAME}"
if [ $? -eq 0 ]
then
    echo "has been created" > /dev/null 2>&1
else
    VBoxManage hostonlyif create
fi
fi

#修改hostonly网卡
if [[ "$NET_CARD_ACTION" =~ 'update' ]]; then
VBoxManage list hostonlyifs | grep -e "^Name:" | sed "s/Name: *//" | grep "${INTERNAL_NET_WORK_NAME}"
if [ $? -eq 0 ]
then
    VBoxManage hostonlyif ipconfig "${INTERNAL_NET_WORK_NAME}" --ip $NET_WORK_IP --netmask $NET_WORK_MASK
fi
fi

#删除hostonly网卡
if [[ "$NET_CARD_ACTION" =~ 'remove' ]]; then
VBoxManage list hostonlyifs | grep -e "^Name:" | sed "s/Name: *//" | grep "${INTERNAL_NET_WORK_NAME}"
if [ $? -eq 0 ]
then
    VBoxManage hostonlyif remove "${INTERNAL_NET_WORK_NAME}"
fi
fi

#列出hostonly网卡
if [[ "$NET_CARD_ACTION" =~ 'list' ]]; then
VBoxManage list hostonlyifs | grep -e "^Name:" | sed "s/Name: *//"
fi

#使用hostonly网络
# 虚拟主机名字
VM_NAME=centos-7.6-clone
# 网卡序号
NET_CARD_NUMBER=1
# 网络类型
NET_WORK_TYPE=host-only
# 网卡类型
NET_CARD_TYPE=82540EM
# 适配器名
HOSET_ONLY_ADAPTER_NAME=$INTERNAL_NET_WORK_NAME
#使用
#VBoxManage modifyvm $VM_NAME --nic2 hostonly --nictype2 $NET_CARD_TYPE --cableconnected2 on --hostonlyadapter2 "VirtualBox Host-Only Ethernet Adapter"
# fix：适配器名字带有空格出现的问题
#VBoxManage modifyvm $VM_NAME --nic2 hostonly --nictype2 $NET_CARD_TYPE --cableconnected2 on --hostonlyadapter2 "${HOSET_ONLY_ADAPTER_NAME}"
#2设置网卡1
#VBoxManage modifyvm $VM_NAME --nic1 hostonly --nictype1 $NET_CARD_TYPE --cableconnected1 on --hostonlyadapter1 "${HOSET_ONLY_ADAPTER_NAME}"
#2设置网卡2
#VBoxManage modifyvm $VM_NAME --nic2 hostonly --nictype2 $NET_CARD_TYPE --cableconnected2 on --hostonlyadapter2 "${HOSET_ONLY_ADAPTER_NAME}"
#2设置网卡N
if [[ "$NET_CARD_ACTION" =~ 'use' ]]; then
$(VBoxManage modifyvm $VM_NAME --nic${NET_CARD_NUMBER} hostonly --nictype${NET_CARD_NUMBER} $NET_CARD_TYPE --cableconnected${NET_CARD_NUMBER} on --hostonlyadapter${NET_CARD_NUMBER} "${HOSET_ONLY_ADAPTER_NAME}")
fi

#### 参考文献
:<<reference
VirtualBox 网络连接方式研究（二）
https://www.iteye.com/blog/815222418-2313457
vboxmanage-modifyvm
https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm
Virtualbox+Centos 7虚拟机设置host-only网卡的静态IP地址
https://blog.csdn.net/yongge1981/article/details/78903886
MY_PROJECT=centos-uses-firewalld
mkdir -p ../$MY_PROJECT
touch ../${MY_PROJECT}/${MY_PROJECT}.sh
reference





