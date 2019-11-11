#!/bin/sh

# 使用virtualbox克隆虚拟主机
# 通过VBoxManage使用virtualbox的cli的方式
# 需要：
# 列出运行中的主机
# 关闭被克隆的主机
# 克隆出某新的主机
# 修改主机名字地址

VMs_PATH="D:\\VirtualBox\\Administrator\\VMs"
mkdir -p $VMs_PATH
cd $VMs_PATH
echo $VMs_PATH
VM_PATH=centos-7.6
mkdir -p $VM_PATH
cd $VM_PATH
PATH_SPLIT_SYMBOL="\\"
VM_BASE_PATH=${VMs_PATH}${PATH_SPLIT_SYMBOL}${VM_PATH}
echo $VM_BASE_PATH

NEW_VM_PATH=centos-7.6-clone
NEW_VM_BASE_FOLEDR=${VMs_PATH}${PATH_SPLIT_SYMBOL}${NEW_VM_PATH}
NEW_VM_NAME=$NEW_VM_PATH
# 列出
VBoxManage list runningvms | sed "s#{.*}##g" | grep $VM_NAME
# 关闭
if [ $? -eq 0 ];then
    VBoxManage controlvm $VM_NAME poweroff
    sleep 5
fi
# 克隆
VBoxManage clonevm $VM_NAME --name $NEW_VM_NAME --register --basefolder $VMs_PATH
#time VBoxManage clonevm $VM_NAME --name $NEW_VM_NAME --register --basefolder $VMs_PATH
sleep 10
# 启动
VBoxManage startvm $NEW_VM_NAME --type headless
# 登录
#ssh root@192.168.2.2
PRIVITE_KEY_FILE_NAME=google-clound-ssr
PRIVITE_KEY_FILE_PATH=~/.ssh/
OLD_VM_SSH_SERVER_IP=192.168.2.2
OLD_VM_SSH_SERVER_USER=root
# ssh -i ${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME} $OLD_VM_SSH_SERVER_IP@$OLD_VM_SSH_SERVER_USER
ssh -t -t -i ${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME} $OLD_VM_SSH_SERVER_IP@$OLD_VM_SSH_SERVER_USER << run-some-task-on-vm-node

####
#functions
####
function update_static_ip(){
#网卡名字
NET_CARD_NAME=eth0
#电脑地址
VM_IPADDR=$1 #192.168.2.2
#网络掩码
VM_NETMASK=255.255.255.0
#网关地址
VM_GATEWAY=192.168.2.1
#某个网络
ONE_NETWORK=192.168.2.0/24
#命令操作
ACTION="SET" #SET|REVOCER
#cat /etc/sysconfig/network-scripts/ifcfg-${NET_CARD_NAME} | grep --extended-regexp "IPADDR.*(.*.)\..*"

#设置
sed -i 's/BOOTPROTO=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NET_CARD_NAME}
sed -i 's/ONBOOT=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NET_CARD_NAME}
sed -i 's/IPADDR=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NET_CARD_NAME}
sed -i 's/NETMASK=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NET_CARD_NAME}
sed -i 's/GATEWAY=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NET_CARD_NAME}
sed -i '/^\s*$/d' /etc/sysconfig/network-scripts/ifcfg-${NET_CARD_NAME} # 删除空格
cat >> /etc/sysconfig/network-scripts/ifcfg-${NET_CARD_NAME} <<centos-set-static-ip-address
IPADDR=${VM_IPADDR}
NETMASK=${VM_NETMASK}
GATEWAY=${VM_GATEWAY}
BOOTPROTO=static
ONBOOT=yes
centos-set-static-ip-address

#service network restart
# 查看
cat /etc/sysconfig/network-scripts/ifcfg-${NET_CARD_NAME} | grep --extended-regexp "IPADDR.*(.*.)\..*"
}

function set_host_name(){
HOST_NAME=$1 #k8s-master
# 设置
#2 for centos7
hostnamectl set-hostname $HOST_NAME
#2 for centos6
#hostname $HOST_NAME
# 查看
cat /etc/hostname


# 设置
cat /etc/hosts | grep "127.0.0.1" | grep $HOST_NAME > /dev/null 2>&1
if [ $? -eq 0 ];then
  echo "yes" > /dev/null 2>&1
  else
  #echo  "no"
  # 在匹配的行前添加#(注释)
  #sed  '/127.0.0.1 */ s/^/#/g' /etc/hosts
  # 在匹配的行后添加（追加）
  #sed -i "/127.0.0.1 */ s/$/ $HOST_NAME/g" /etc/hosts
  # 删除后添加（覆盖）
  #sed "s/127.0.0.1.*//g" /etc/hosts | sed '/^\s*$/d'
  sed -i "s/127.0.0.1.*//g" /etc/hosts
  sed -i '/^\s*$/d' /etc/hosts
  echo "127.0.0.1 $HOST_NAME" >> /etc/hosts
fi

cat /etc/hosts | grep "::1" | grep $HOST_NAME > /dev/null 2>&1
if [ $? -eq 0 ];then
  echo "yes" > /dev/null 2>&1
  else
  #echo  "no"
  # 在匹配的行前添加#
  #sed  '/::1 */ s/^/#/g' /etc/hosts
  # 在匹配的行后添加#
  #sed -i "/::1 */ s/$/ $HOST_NAME/g" /etc/hosts
  sed -i "s/::1.*//g" /etc/hosts
  sed -i '/^\s*$/d' /etc/hosts
  echo "::1 $HOST_NAME" >> /etc/hosts
fi

# 查看
cat /etc/hosts
}

####
#actions
####
# 操作
#2 修改ip
update_static_ip 192.168.2.3
#2 修改hostname
set_host_name k8s-node-3
#2 ...
# 重启
sleep 10
reboot
run-some-task-on-vm-node