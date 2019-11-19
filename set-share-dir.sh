#!/bin/sh

# 共享物理机win上的某一目录到virtualbox中的虚拟机centos的某一目录
# 需要：
# 在物理机上的git-bash上执行相关命令
# 在虚拟机上的shell上执行相关命令


# 帮助信息
THIS_FILE_PATH=$(cd `dirname $0`; pwd)
USAGE_MSG_PATH=${THIS_FILE_PATH}/help
USAGE_MSG_FILE=${USAGE_MSG_PATH}/set-share-dir.txt
# 参数规则
GETOPT_ARGS_SHORT_RULE="--options h,d,m:"
GETOPT_ARGS_LONG_RULE="--long help,debug,machine:,vm-name:,pm-share-name:,pm-share-dir:,vm-mount-dir:"

function ouput_debug_msg(){
local debug_msg=$1
local debug_swith=$2
if [[ "$debug_swith" =~ "false" ]] ; 
then 
    echo $debug_msg > /dev/null 2>&1
elif [ -n "$debug_swith" ]
then
    echo $debug_msg ; 
elif [[ "$debug_swith" =~ "true" ]] ; 
then
    echo $debug_msg ; 
    #echo $debug_msg > /dev/null 2>&1
fi
}
####function-usage
# ouput_debug_msg "pm" "false"
# ouput_debug_msg "pm"

# 设置参数规则
GETOPT_ARGS=`getopt $GETOPT_ARGS_SHORT_RULE \
$GETOPT_ARGS_LONG_RULE -- "$@"`
# 解析参数规则
eval set -- "$GETOPT_ARGS"
# 更新新的配置
MACHINE=
while [ -n "$1" ]
do
    case $1 in
    -m|--machine) #可选，必接参数
    MACHINE=$2
    shift 2
    ;;
    --vm-name) #可选，必接参数
    ARG_VM_NAME=$2
    shift 2
    ;;
    --pm-share-name) #可选，必接参数
    ARG_PM_SHARE_NAME=$2
    shift 2
    ;;
    --pm-share-dir) #可选，必接参数
    ARG_PM_SHARE_DIR=$2
    shift 2
    ;;
    --vm-mount-dir) #可选，必接参数
    ARG_VM_MOUNT_DIR=$2
    shift 2
    ;;
    -h|--help) #可选，不接参数
    cat $USAGE_MSG_FILE
    exit 1
    ;;
    -d|--debug) #可选，不接参数
    IS_DEBUG_MODE=true
    shift 2
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
ouput_debug_msg "handle the rest args ..." "true"
#...

ouput_debug_msg "update built-in config ..." "true"
#物机共享目录
PM_SHARE_DIR="D:\\hand-book-yemiancheng"
if [ -n "$ARG_PM_SHARE_DIR" ]
then
    PM_SHARE_DIR=$ARG_PM_SHARE_DIR
fi
#物机共享名字
PM_SHARE_NAME="hand-book-yemiancheng"
if [ -n "$ARG_PM_SHARE_NAME" ]
then
    PM_SHARE_DIR=$ARG_PM_SHARE_NAME
fi
#虚拟机的名字
VM_NAME=centos-7.6
if [ -n "$ARG_VM_NAME" ]
then
    ouput_debug_msg "update config VM_NAME ..." $IS_DEBUG_MODE
    VM_NAME=$ARG_VM_NAME
fi
#虚机挂载目录
VM_MOUNT_DIR=/mnt/hand-book-yemiancheng
if [ -n "$ARG_VM_MOUNT_DIR" ]
then
    ouput_debug_msg "update config VM_MOUNT_DIR ..." $IS_DEBUG_MODE
    VM_MOUNT_DIR=$ARG_VM_MOUNT_DIR
fi

#echo $PM_SHARE_NAME,$PM_SHARE_DIR,$VM_NAME,$VM_MOUNT_DIR,$MACHINE

function run_mount_on_pm(){
###
# on pm git-bash:
###
# 创建共享目录
# 将物理机的$PM_SHARE_DIR目录共享给虚拟机$VM_NAME，且共享名为$PM_SHARE_NAME
#2 永久
VBoxManage sharedfolder add $VM_NAME --name $PM_SHARE_NAME --hostpath $PM_SHARE_DIR --automount
#2 瞬间
#VBoxManage sharedfolder add $VM_NAME --name $PM_SHARE_NAME --hostpath $PM_SHARE_DIR --transient
# 删除共享目录
#2 永久
#VBoxManage sharedfolder remove $VM_NAME --name $PM_SHARE_NAME
}
function run_mount_on_vm(){
###
# on vm bash:
###
cat /etc/fstab
# 建挂载点
mkdir -p $VM_MOUNT_DIR
mount -t vboxsf $PM_SHARE_NAME $VM_MOUNT_DIR
# 自动挂载
cat > /etc/fstab < EOF
$PM_SHARE_NAME         $$VM_MOUNT_DIR  vboxsf    rw,gid=100,uid=1000,auto        0 0
EOF
# 查挂载点
mount | grep $PM_SHARE_NAME

# yum whatprovides unmount
# 删挂载点
#umount -v $VM_MOUNT_DIR
}

function mount_share_dir(){
local MACHINE_ON=$1
if [[ $MACHINE_ON = "pm" ]]
then
    # on pm git-bash:
    ouput_debug_msg "mount share dir on pm ..." "true"
    run_mount_on_pm
elif [[ $MACHINE_ON = "vm" ]]
then
    # on vm bash:
    ouput_debug_msg "mount share dir on vm ..." "true"
    run_mount_on_vm
fi
}
####function-usage
# mount_share_dir pm
# mount_share_dir vm
mount_share_dir $MACHINE

#### 参考文献
:<<reference
VBoxManage 共享文件
https://www.cnblogs.com/sunson/articles/2285134.html
reference
