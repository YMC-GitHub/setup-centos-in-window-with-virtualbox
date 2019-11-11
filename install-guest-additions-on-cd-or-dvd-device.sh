#!/bin/sh

##########
#安装 Guest Additions
##########
:<<install-guest-additions-on-cd-or-dvd-device
# 通过挂载光驱，安装virtualbox增强功能
####### 为什么要
# 安装增强功能后，鼠标可以在虚拟机和主机之间自由切换。
# 安装增强功能后，可以使用主机和虚拟机之间文件夹共享及双向拷贝。
####### 如何进行
# on pm git-bash:

VM_NAME=centos-7.6
# 设置存储
#2 建存储控制器
#VBoxManage storagectl $VM_NAME --name $STORAGE_CONTROLLER_IDE_NAME --add ide --controller $STORAGE_CONTROLLER_IDE_TYPE --bootable on
#2 删除储控制器
#VBoxManage storagectl $VM_NAME --name $STORAGE_CONTROLLER_IDE_NAME --remove 
# 关联镜像（插入光盘）
IDE_DEVICE=0 #存储控制器ide设备编号
IDE_PORT=0 #存储控制器ide设备端口
VBOX_GUEST_ADDITIONS_FILE="E:\\Program Files\\Oracle\\VirtualBox\\VBoxGuestAdditions.iso"
STROAGE_TYPE=dvddrive #存储驱动类型
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --device $IDE_DEVICE --port $IDE_PORT  --type $STROAGE_TYPE --medium "E:\\Program Files\\Oracle\\VirtualBox\\VBoxGuestAdditions.iso"
#VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --device $IDE_DEVICE --port $IDE_PORT  --type $STROAGE_TYPE --medium $VBOX_GUEST_ADDITIONS_FILE

# on vm bash:
# 挂载镜像（挂载光驱）
#挂载到的目录
VM_MOUT_ISO_DIR=/mnt/VBoxGuestAdditions
mkdir -p $VM_MOUT_ISO_DIR
#光驱所在目录
VM_ROM_NAME=$(ls /dev| grep "cdrom\dvdrom")
VM_ROM_DIR=/dev${VM_ROM_NAME}
#挂载
sudo mount -t auto $VM_MOUT_ISO_DIR $VM_ROM_DIR #cat /dev
#安装
cd $VM_MOUT_ISO_DIR
sudo ./VBoxLinuxAdditions.run
# 卸载镜像
sudo umount $VM_MOUT_ISO_DIR
# 删除目录
rm -rf  $VM_MOUT_ISO_DIR
# 重启电脑
sudo reboot

install-guest-additions-on-cd-or-dvd-device


#安装VBoxGuestAdditions
:<<install-VBoxGuestAdditions-on-centos
wget http://download.virtualbox.org/virtualbox/4.3.8/VBoxGuestAdditions_4.3.8.iso
sudo mkdir /media/VBoxGuestAdditions
sudo mount -o loop,ro VBoxGuestAdditions_4.3.8.iso /media/VBoxGuestAdditions
sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
rm VBoxGuestAdditions_4.3.8.iso
sudo umount /media/VBoxGuestAdditions
sudo rmdir /media/VBoxGuestAdditions
install-VBoxGuestAdditions-on-centos