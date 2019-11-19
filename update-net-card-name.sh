#!/bin/sh

# centos7修改网卡名字
# 需要：
# 查找网卡配置文件
# 查看网卡配置文件
# 命名网卡配置文件
# 修改配置文件内容
# 重新启动网络服务
# 重新启动电脑生效


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
USAGE_MSG_CONTENT=$(cat<<EOF 
update net card name
args:
  --old-net-card-file-reg optional,set the old new card file name reg
  --new-net-card-name optional,set the new net card name
  -d,--debug optional,set the debug mode
  -h,--help optional,get the cmd help
examples: 
  run as shell args
bash ./update-net-card-name.sh
  run as runable application
./update-net-card-name.sh --new-net-card-name eth0

  without args: 
./update-net-card-name.sh 
  with args: 
./update-net-card-name.sh --new-net-card-name eth0

  with debug mode: 
./update-net-card-name.sh --debug

get help: 
./update-net-card-name.sh --help
EOF
)

# 设置参数规则
GETOPT_ARGS_SHORT_RULE="--options h,d"
GETOPT_ARGS_LONG_RULE="--long help,debug,old-net-card-file-reg:,new-net-card-name:"
GETOPT_ARGS=`getopt $GETOPT_ARGS_SHORT_RULE \
$GETOPT_ARGS_LONG_RULE -- "$@"`
# 解析参数规则
ouput_debug_msg "parse the args passed by cli ..." "true"
eval set -- "$GETOPT_ARGS"
while [ -n "$1" ]
do
    case $1 in
    --old-net-card-file-reg) #可选，必接参数
    ARG_OLD_NET_CARD_FILE_REG=$2
    shift 2
    ;;
    --new-net-card-name) #可选，必接参数
    ARG_NEW_NET_CARD_NAME=$2
    shift 2
    ;;
    -h|--help) #可选，不接参数
    echo "$USAGE_MSG_CONTENT"
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
    echo "$USAGE_MSG_CONTENT"
    ;;
    esac
done

#处理剩余的参数
ouput_debug_msg "handle the rest args ..." "true"
#...
ouput_debug_msg "update built-in config ..." "true"


# 查看系统版本
cat /etc/redhat-release
# 网卡名字正则
OLD_NET_CARD_FILE_REG=ifcfg-en
NEW_NET_CARD_NAME=eth0
NET_CARD_FILE_PATH=/etc/sysconfig/network-scripts
NEW_NET_CARD_FILE_NAME_PREFIX=ifcfg-

if [ -n "$ARG_NEW_NET_CARD_NAME" ]
then
    NEW_NET_CARD_NAME=$ARG_NEW_NET_CARD_NAME
fi
if [ -n "$ARG_OLD_NET_CARD_FILE_REG" ]
then
    OLD_NET_CARD_FILE_REG=$ARG_OLD_NET_CARD_FILE_REG
fi


NEW_NET_CARD_FILE_NAME=${NEW_NET_CARD_FILE_NAME_PREFIX}${NEW_NET_CARD_NAME}
OLD_NET_CARD_FILE_NAME=

# 查找网卡配置文件
OLD_NET_CARD_FILE_NAME=$(ls $NET_CARD_FILE_PATH | grep $OLD_NET_CARD_FILE_REG)
echo $OLD_NET_CARD_FILE_NAME
# 查看网卡配置文件
cat $NET_CARD_FILE_PATH/$OLD_NET_CARD_FILE_NAME

# 命名网卡配置文件
mv $NET_CARD_FILE_PATH/$OLD_NET_CARD_FILE_NAME $NET_CARD_FILE_PATH/$NEW_NET_CARD_FILE_NAME
ls $NET_CARD_FILE_PATH | grep $NEW_NET_CARD_FILE_NAME

# 修改网卡配置文件内容
sed -i "s/^NAME=.*/NAME=\"$NEW_NET_CARD_NAME\"/g" $NET_CARD_FILE_PATH/$NEW_NET_CARD_FILE_NAME
sed -i "s/^DEVICE=.*/DEVICE=\"$NEW_NET_CARD_NAME\"/g" $NET_CARD_FILE_PATH/$NEW_NET_CARD_FILE_NAME
# 查看网卡配置文件内容
cat $NET_CARD_FILE_PATH/$NEW_NET_CARD_FILE_NAME | grep "$NEW_NET_CARD_FILE_NAME"
# 重启网络服务
#systemctl restart network
service network restart

# 查看该可预测命名规则
#cat /etc/default/grub
# 禁用该可预测命名规则
LABEL_VAL="rd.lvm.lv=centos/swap "
INSERT_VAL="net.ifnames=0 biosdevname=0 "
sed -i "s#$INSERT_VAL##g" /etc/default/grub
sed -i "s#$LABEL_VAL#$LABEL_VAL$INSERT_VAL#g" /etc/default/grub

# 生成GRUB配置并更新内核参数
grub2-mkconfig --output /boot/grub2/grub.cfg
# 重启系统
reboot

#### note
# 编码脚本
#cat update-net-card-name.sh
# 赋予权限
#chmod +x update-net-card-name.sh
# 上传脚本
# 下载脚本
# 使用脚本
# cd /to/the/path/
# ./update-net-card-name.sh
