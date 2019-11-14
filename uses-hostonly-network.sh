#!/bin/sh

# 使用hostonly
# 需要：
# 创建hostonly网卡
# 使用hostonly网卡

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

# 帮助信息
THIS_FILE_PATH=$(cd `dirname $0`; pwd)
USAGE_MSG_PATH=${THIS_FILE_PATH}/help
USAGE_MSG_FILE=${USAGE_MSG_PATH}/uses-hostonly-network.txt
# 参数规则
GETOPT_ARGS_SHORT_RULE="--options h,d"
GETOPT_ARGS_LONG_RULE="--long help,debug,vm-name:,actions:,id:"

# 设置参数规则
GETOPT_ARGS=`getopt $GETOPT_ARGS_SHORT_RULE \
$GETOPT_ARGS_LONG_RULE -- "$@"`
# 解析参数规则
ouput_debug_msg "parse the args passed by cli ..." "true"
eval set -- "$GETOPT_ARGS"
while [ -n "$1" ]
do
    case $1 in
    --vm-name) #可选，必接参数
    ARG_VM_NAME=$2
    shift 2
    ;;
    --actions) #可选，必接参数
    ARG_ACTIONS=$2
    shift 2
    ;;
    --id) #可选，必接参数
    ARG_ID=$2
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
# 网卡名字前缀
INTERNAL_NET_WORK_NAME_PREFIX="VirtualBox Host-Only Ethernet Adapter"
#INTERNAL_NET_WORK_NAME_ID="" # "#2|"
# 网卡名字编号
INTERNAL_NET_WORK_NAME_ID="#2"
if [ -n "$ARG_ID" ]
then
    INTERNAL_NET_WORK_NAME_ID=$ARG_ID
fi
# 网卡名字
INTERNAL_NET_WORK_NAME=
# 网络地址
NET_WORK_IP=192.168.2.1
# 网络掩码
NET_WORK_MASK=255.255.255
# 网卡操作
NET_CARD_ACTION="create|update|list|use" #"create|update|remove|list|use"
if [ -n "$ARG_ACTIONS" ]
then
    NET_CARD_ACTION=$ARG_ACTIONS
fi

# 生成网卡名字
ouput_debug_msg "generate net adanpter name..." "true"
if [ -n $INTERNAL_NET_WORK_NAME_ID ]
then
    INTERNAL_NET_WORK_NAME="$INTERNAL_NET_WORK_NAME_PREFIX $INTERNAL_NET_WORK_NAME_ID"
else
    INTERNAL_NET_WORK_NAME=$INTERNAL_NET_WORK_NAME_PREFIX
fi
#echo $INTERNAL_NET_WORK_NAME

#echo $INTERNAL_NET_WORK_NAME_ID,$VM_NAME,$NET_CARD_ACTION

#创建hostonly网卡
if [[ "$NET_CARD_ACTION" =~ 'create' ]]; then
    VBoxManage list hostonlyifs | grep -e "^Name:" | sed "s/Name: *//" | grep "${INTERNAL_NET_WORK_NAME}"
    if [ $? -eq 0 ]
    then
        echo "has been created" > /dev/null 2>&1
    else
        ouput_debug_msg "create net adanpter on pm" "true"
        VBoxManage hostonlyif create
    fi
fi

#修改hostonly网卡
if [[ "$NET_CARD_ACTION" =~ 'update' ]]; then
    VBoxManage list hostonlyifs | grep -e "^Name:" | sed "s/Name: *//" | grep "${INTERNAL_NET_WORK_NAME}"
    if [ $? -eq 0 ]
    then
        ouput_debug_msg "edit net adapter on pm" "true"
        VBoxManage hostonlyif ipconfig "${INTERNAL_NET_WORK_NAME}" --ip $NET_WORK_IP --netmask $NET_WORK_MASK
    fi
fi

#删除hostonly网卡
if [[ "$NET_CARD_ACTION" =~ 'remove' ]]; then
    VBoxManage list hostonlyifs | grep -e "^Name:" | sed "s/Name: *//" | grep "${INTERNAL_NET_WORK_NAME}"
    if [ $? -eq 0 ]
    then
        ouput_debug_msg "remove net adapter on pm" "true"
        VBoxManage hostonlyif remove "${INTERNAL_NET_WORK_NAME}"
    fi
fi

#列出hostonly网卡
if [[ "$NET_CARD_ACTION" =~ 'list' ]]; then
    ouput_debug_msg "list net adapter on pm" "true"
    VBoxManage list hostonlyifs | grep -e "^Name:" | sed "s/Name: *//"
fi

#使用hostonly网络
# 虚拟主机名字
VM_NAME=centos-7.6-clone
if [ -n "$ARG_VM_NAME" ]
then
    VM_NAME=$ARG_VM_NAME
fi
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
    ouput_debug_msg "use net adapter ..." "true"
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





