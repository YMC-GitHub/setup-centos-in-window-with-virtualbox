#!/bin/sh

# 共享物理机win上的某一目录到virtualbox中的虚拟机centos的某一目录
# 需要：
# 在物理机上的git-bash上执行相关命令
# 在虚拟机上的shell上执行相关命令

:<<set-share-dir-for-vm
###
# on pm git-bash:
###
# 创建共享目录
# 将物理机的$PM_SHARE_DIR目录共享给虚拟机$VM_NAME，且共享名为$PM_SHARE_NAME
PM_SHARE_DIR="D:\\hand-book-yemiancheng"
PM_SHARE_NAME="hand-book-yemiancheng"
VM_NAME=centos-7.6
#2 永久
VBoxManage sharedfolder add $VM_NAME --name $PM_SHARE_NAME --hostpath $PM_SHARE_DIR --automount
#2 瞬间
VBoxManage sharedfolder add $VM_NAME --name $PM_SHARE_NAME --hostpath $PM_SHARE_DIR --transient

# 删除共享目录
#2 永久
VBoxManage sharedfolder remove $VM_NAME --name $PM_SHARE_NAME

###
# on vm bash:
###
cat /etc/fstab
# 建挂载点
PM_SHARE_NAME="hand-book-yemiancheng"
VM_SHARE_DIR=/mnt/hand-book-yemiancheng
mkdir -p $VM_SHARE_DIR
mount -t vboxsf $PM_SHARE_NAME $VM_SHARE_DIR
# 自动挂载
cat > /etc/fstab < EOF
$PM_SHARE_NAME         $$VM_SHARE_DIR  vboxsf    rw,gid=100,uid=1000,auto        0 0
EOF
# 查挂载点
mount | grep $PM_SHARE_NAME

# yum whatprovides unmount
# 删挂载点
umount -v $VM_SHARE_DIR

#### 参考文献
:<<reference
VBoxManage 共享文件
https://www.cnblogs.com/sunson/articles/2285134.html
reference
set-share-dir-for-vm