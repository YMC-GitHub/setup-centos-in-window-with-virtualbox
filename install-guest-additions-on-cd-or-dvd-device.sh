#!/bin/sh

##########
#安装 Guest Additions
##########
#:<<install-guest-additions-on-cd-or-dvd-device
# 通过挂载光驱，安装virtualbox增强功能

####### 为什么要
# 安装增强功能后，鼠标可以在虚拟机和主机之间自由切换。
# 安装增强功能后，可以使用主机和虚拟机之间文件夹共享及双向拷贝。
####### 如何进行
function run_on_pm(){
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
}
####function-usage
# run_on_pm

function run_on_vm(){
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
}
####function-usage
# run_on_vm

function installs(){
local MACHINE_ON=$1
if [ $MACHINE_ON = "pm" ]
then
    # on pm git-bash:
    run_on_pm
elif [ $MACHINE_ON = "vm" ]
then
    # on vm bash:
    run_on_vm
fi
}
####function-usage
# installs pm
# installs vm
#install-guest-additions-on-cd-or-dvd-device

# 帮助信息
THIS_FILE_PATH=$(cd `dirname $0`; pwd)
USAGE_MSG_PATH=${THIS_FILE_PATH}/help
USAGE_MSG_FILE=${USAGE_MSG_PATH}/install-guest-additions.txt
# 参数规则
GETOPT_ARGS_SHORT_RULE="--options h,d,m:"
GETOPT_ARGS_LONG_RULE="--long help,debug,machine:"

# 设置参数规则
GETOPT_ARGS=`getopt $GETOPT_ARGS_SHORT_RULE \
$GETOPT_ARGS_LONG_RULE -- "$@"`
# 解析参数规则
eval set -- "$GETOPT_ARGS"
# 更新新的配置
IS_PM=
IS_VM=
MACHINE=
while [ -n "$1" ]
do
    case $1 in
    -m|--machine) #可选，必接参数
    MACHINE=$2
    shift 2
    ;;
    -h|--help) #可选，不接参数
    cat $USAGE_MSG_FILE
    exit 1
    ;;
    -d|--debug) #可选，不接参数
    IS_DEBUG_MODE=true
    ;;
    --)
    break
    ;;
    *)
    printf "$USAGE_MSG"
    ;;
    esac
done

#处理剩余的参数
#...
if [[ "$MACHINE" =~ "pm" ]] ; 
then 
    installs "pm"
elif [[ "$MACHINE" =~ "vm" ]] ; 
then
    installs "vm"
else
    installs "pm"
fi 
}

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