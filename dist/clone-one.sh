#!/bin/sh

# 使用virtualbox克隆虚拟主机
# 通过VBoxManage使用virtualbox的cli的方式
# 需要：
# 列出运行中的主机
# 关闭被克隆的主机
# 克隆出某新的主机
# 免密登录新的主机
# 修改主机名字地址
# 修改域名解析地址


#主机列表目录
VMs_PATH="D:\\VirtualBox\\Administrator\\VMs"
#被克隆机目录
VM_PATH=k8s-node-8
#路径分割符号
PATH_SPLIT_SYMBOL="\\"
#新的主机路径
NEW_VM_PATH=k8s-node-9
#私钥文件名字
PRIVITE_KEY_FILE_NAME=google-clound-ssr
#私钥文件路径
PRIVITE_KEY_FILE_PATH=~/.ssh/
#被克隆机ssh服务地址
OLD_VM_SSH_SERVER_IP=192.168.2.2
#被克隆机ssh服务账户
OLD_VM_SSH_SERVER_USER=root
#新的主机ssh服务地址
NEW_VM_SSH_SERVER_IP=192.168.2.9
#新的主机ssh服务账户
NEW_VM_SSH_SERVER_USER=root

ACTIONS="close_old_vm|clone_old_vm|start_new_vm||list|use" #"start_new_vm|restart_new_vm|ssh_new_vm"


#某个网络
ONE_NETWORK=192.168.2.0/24
#网卡名字
NEW_VM_NET_CARD_NAME=eth0
#网络掩码
NEW_VM_NETMASK=255.255.255.0
#网关地址
NEW_VM_GATEWAY=192.168.2.1

# 帮助信息
THIS_FILE_PATH=$(cd `dirname $0`; pwd)
USAGE_MSG_PATH=${THIS_FILE_PATH}/help
USAGE_MSG_FILE=${USAGE_MSG_PATH}/clone-one.txt
# 参数规则
GETOPT_ARGS_SHORT_RULE="--options h,d"
GETOPT_ARGS_LONG_RULE="--long help,debug,new-vm-name:,old-vm-name:,old-vm-ip:,new-vm-ip:,path-delimeter-char:,key-file-name:,key-file-path:,old-vm-user:,actions:"

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
fi
}
####function-usage
# ouput_debug_msg "pm" "false"
# ouput_debug_msg "pm"


# 设置参数规则
GETOPT_ARGS=`getopt $GETOPT_ARGS_SHORT_RULE \
$GETOPT_ARGS_LONG_RULE -- "$@"`
# 解析参数规则
ouput_debug_msg "pasre cli args ..." "true"
eval set -- "$GETOPT_ARGS"
MACHINE=


while [ -n "$1" ]
do
    case $1 in
    --new-vm-name)
    ARG_NEW_VM_NAME=$2
    shift 2
    ;;
    --old-vm-name)
    ARG_OLD_VM_NAME=$2
    shift 2
    ;;
    --old-vm-ip)
    ARG_OLD_VM_IP=$2
    shift 2
    ;;
    --new-vm-ip)
    ARG_NEW_VM_IP=$2
    shift 2
    ;;
    --path-delimeter-char)
    ARG_PATH_DELIMETER_CHAR=$2
    shift 2
    ;;
    --key-file-name)
    ARG_KEY_FILE_NAME=$2
    shift 2
    ;;
    --key-file-path)
    ARG_KEY_FILE_PATH=$2
    shift 2
    ;;
    --old-vm-user)
    ARG_OLD_VM_USER=$2
    shift 2
    ;;
    --actions) #可选，必接参数
    ARG_ACTIONS=$2
    shift 2
    ;;
    -h|--help) #可选，不接参数
    #echo "$USAGE_MSG_FILE"
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
if [ -n "$ARG_KEY_FILE_PATH" ]
then
    PRIVITE_KEY_FILE_PATH=$ARG_KEY_FILE_PATH
fi
if [ -n "$ARG_OLD_VM_NAME" ]
then
    VM_PATH=$ARG_OLD_VM_NAME
fi
if [ -n "$ARG_NEW_VM_NAME" ]
then
    NEW_VM_PATH=$ARG_NEW_VM_NAME
fi
if [ -n "$ARG_NEW_VM_IP" ]
then
    NEW_VM_SSH_SERVER_IP=$ARG_NEW_VM_IP
fi
if [ -n "$ARG_OLD_VM_USER" ]
then
    OLD_VM_SSH_SERVER_USER=$ARG_OLD_VM_USER
fi
if [ -n "$ARG_PATH_DELIMETER_CHAR" ]
then
    PATH_SPLIT_SYMBOL=$ARG_PATH_DELIMETER_CHAR
fi
if [ -n "$ARG_KEY_FILE_NAME" ]
then
    PRIVITE_KEY_FILE_NAME=$ARG_KEY_FILE_NAME
fi
if [ -n "$ARG_OLD_VM_IP" ]
then
    OLD_VM_SSH_SERVER_IP=$ARG_OLD_VM_IP
fi

#echo $OLD_VM_SSH_SERVER_IP,$VM_PATH


# 计算相关变量
ouput_debug_msg "caculate relations config ..." "true"
#被克隆机基径
VM_BASE_PATH=${VMs_PATH}${PATH_SPLIT_SYMBOL}${VM_PATH}
#被克隆机名字
VM_NAME=$VM_PATH
#新的主机基径
NEW_VM_BASE_FOLEDR=${VMs_PATH}${PATH_SPLIT_SYMBOL}${NEW_VM_PATH}
#新的主机名字
NEW_VM_NAME=$NEW_VM_PATH
#新的主机host名字
NEW_VM_HOST_NAME=$NEW_VM_NAME
#电脑地址
NEW_VM_IPADDR=$NEW_VM_SSH_SERVER_IP

if [ -n "$ARG_ACTIONS" ]
then
    ACTIONS=$ARG_ACTIONS
fi


# 生成相关目录
ouput_debug_msg "generate relations dir and file ..." "true"
mkdir -p $VMs_PATH
cd $VMs_PATH
mkdir -p $VM_PATH
cd $VM_PATH

if [[ "$ACTIONS" =~ 'clone_old_vm' ]]; then
# 关闭被克隆机
ouput_debug_msg "close old vm $VM_NAME..." "true"
VBoxManage list runningvms | sed "s#{.*}##g" | grep $VM_NAME
if [ $? -eq 0 ];then
    VBoxManage controlvm $VM_NAME poweroff
    sleep 10
fi
# 克隆被克隆机
VBoxManage list vms | sed "s#{.*}##g" | grep $NEW_VM_NAME
if [ $? -eq 0 ]
then
    echo "need to clone a vm" > /dev/null 2>&1
else 
    ouput_debug_msg "clone old vm $VM_NAME..." "true"
    VBoxManage clonevm $VM_NAME --name $NEW_VM_NAME --register --basefolder $VMs_PATH
    sleep 40
fi
fi

if [[ "$ACTIONS" =~ 'start_new_vm' ]]; then
# 启动新的主机
VBoxManage list runningvms | sed "s#{.*}##g" | grep $NEW_VM_NAME
if [ $? -eq 0 ]
then
  echo "has been started before" > /dev/null 2>&1
else
  ouput_debug_msg "start new vm ..." "true"
  VBoxManage startvm $NEW_VM_NAME --type headless
fi
sleep 60
fi


# 登录新的主机
# 运行相关事务
#2 ...
#ssh root@192.168.2.2
# ssh -i ${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME} $OLD_VM_SSH_SERVER_USER@$OLD_VM_SSH_SERVER_IP
# ssh -tt -i ${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME} $OLD_VM_SSH_SERVER_USER@$OLD_VM_SSH_SERVER_IP

# 关机新的主机
if [[ "$ACTIONS" =~ 'restart_new_vm' ]]; then
VBoxManage list runningvms | sed "s#{.*}##g" | grep $NEW_VM_NAME
if [ $? -eq 0 ]
then
  sleep 3
  ouput_debug_msg "close new vm ..." "true"
  VBoxManage controlvm $NEW_VM_NAME poweroff
fi
sleep 40

# 重启新的主机
VBoxManage list runningvms | sed "s#{.*}##g" | grep $NEW_VM_NAME
if [ $? -eq 0 ]
then
  echo "has been started before" > /dev/null 2>&1
else
  ouput_debug_msg "start new vm ..." "true"
  VBoxManage startvm $NEW_VM_NAME --type headless
fi
sleep 60
fi

# 再登新的主机
if [[ "$ACTIONS" =~ 'ssh_new_vm' ]]; then
  ouput_debug_msg "ssh to new vm ..." "true"
  ssh -t -i ${PRIVITE_KEY_FILE_PATH}${PRIVITE_KEY_FILE_NAME} $NEW_VM_SSH_SERVER_USER@$NEW_VM_SSH_SERVER_IP
fi

#### usage
