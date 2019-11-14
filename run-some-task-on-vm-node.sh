#!/bin/sh

#### 一些任务
# 在vm节点上执行
# 任务：
# 更新静态网络地址
# 设置虚机主机名字
# 设置其域名服务器
# ...

####
#functions
####
function update_static_ip(){
#设置
if [ -e /etc/sysconfig/network-scripts/ifcfg-${NEW_VM_NET_CARD_NAME} ]
then
echo "update ip in net card :${NEW_VM_NET_CARD_NAME}"
sed -i 's/IPADDR=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NEW_VM_NET_CARD_NAME}
sed -i 's/NETMASK=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NEW_VM_NET_CARD_NAME}
sed -i 's/GATEWAY=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NEW_VM_NET_CARD_NAME}
sed -i 's/BOOTPROTO=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NEW_VM_NET_CARD_NAME}
sed -i 's/ONBOOT=.*//g' /etc/sysconfig/network-scripts/ifcfg-${NEW_VM_NET_CARD_NAME}
sed -i '/^\s*$/d' /etc/sysconfig/network-scripts/ifcfg-${NEW_VM_NET_CARD_NAME} # 删除空格
fi
cat >> /etc/sysconfig/network-scripts/ifcfg-${NEW_VM_NET_CARD_NAME} <<centos-set-static-ip-address
IPADDR=${NEW_VM_IPADDR}
NETMASK=${NEW_VM_NETMASK}
GATEWAY=${NEW_VM_GATEWAY}
BOOTPROTO=static
ONBOOT=yes
centos-set-static-ip-address

#service network restart
# 查看
cat /etc/sysconfig/network-scripts/ifcfg-${NEW_VM_NET_CARD_NAME} | grep --extended-regexp "IPADDR.*(.*.)\..*"
}

function set_host_name(){
# 设置
#2 for centos7
hostnamectl set-hostname $NEW_VM_HOST_NAME
#2 for centos6
#hostname $NEW_VM_HOST_NAME

# 查看
cat /etc/hostname


# 设置
#cat /etc/hosts | grep "127.0.0.1" | grep "${NEW_VM_HOST_NAME}" > /dev/null 2>&1

  #echo  "no"
  # 在匹配的行前添加#(注释)
  #sed  '/127.0.0.1 */ s/^/#/g' /etc/hosts
  # 在匹配的行后添加（追加）
  #sed -i "/127.0.0.1 */ s/$/ $NEW_VM_HOST_NAME/g" /etc/hosts
  # 删除后添加（覆盖）
  #sed "s/127.0.0.1.*//g" /etc/hosts | sed '/^\s*$/d'
  sed -i "s/127.0.0.1.*//g" /etc/hosts
  sed -i '/^\s*$/d' /etc/hosts
  echo "127.0.0.1 $NEW_VM_HOST_NAME" >> /etc/hosts

#cat /etc/hosts | grep "::1" | grep $NEW_VM_HOST_NAME > /dev/null 2>&1
  #echo  "no"
  # 在匹配的行前添加#
  #sed  '/::1 */ s/^/#/g' /etc/hosts
  # 在匹配的行后添加#
  #sed -i "/::1 */ s/$/ $NEW_VM_HOST_NAME/g" /etc/hosts
  sed -i "s/::1.*//g" /etc/hosts
  sed -i '/^\s*$/d' /etc/hosts
  echo "::1 $NEW_VM_HOST_NAME" >> /etc/hosts

# 查看
cat /etc/hosts
}

function set_dns_resovle_in_china(){
cat > /etc/resolv.conf  << set-host_dns_resovle
nameserver 223.5.5.5
nameserver 223.6.6.6
set-host_dns_resovle
cat /etc/resolv.conf
}

####
#actions
####
# 操作
#2 修改ip
update_static_ip
#2 修改hostname
set_host_name
#2 修改dns域名服务器
set_dns_resovle_in_china
#2 ...
# 退出
sleep 10
exit