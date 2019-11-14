
#!/bin/sh

# 使用virtualbox创建虚拟主机
# 通过VBoxManage使用virtualbox的cli的方式
# 需要：
# 创建某虚拟机
# 设置系统类型
# 设置内核数量
# 设置内存大小
# 建立虚拟磁盘
# 建存储控制器
# 关联虚机磁盘
# 关联镜像文件
# 设置网络连接


# 注：win 系统下以管理员身份运行git-bash，在其窗口下运行此脚本

#创建某个字典
declare -A dic
dic=()

###
# 脚本内置配置
###
#主机列表目录
dic['VMs_PATH']="D:\\VirtualBox\\Administrator\\VMs"
#本虚拟机目录
dic['VM_PATH']=centos-7.6
#路径间隔符号
dic['PATH_SPLIT_SYMBOL']="\\"
#系统类型
dic['OS_TYPE']=Linux
dic['OS_ID']=RedHat_64
#内存大小
dic['MEMORY_SIZE']=4096
#硬盘大小
dic['DISK_SIZE']=20000
#硬盘类型
dic['DISK_TYPE']=.vdi
#存储控制器IDE
dic['STORAGE_CONTROLLER_IDE_NAME']=IDE
dic['STORAGE_CONTROLLER_IDE_TYPE']=PIIX4
#存储控制器SATA
dic['STORAGE_CONTROLLER_SATA_NAME']=SATA
dic['STORAGE_CONTROLLER_SATA_TYPE']=IntelAhci
#镜像文件
dic['OS_ISO_NAME']="D:\\some-important-soflt\\CentOS-7-x86_64-DVD-1908.iso"
#线程数量
dic['CPU_PROCESOOR_NUMBER']=2
# 屏幕控制
dic['DISPLAY_GRAPHICIS_CONTROLLER']=VBoxVGA

:<<ouput-config-key-val-for-debug
# 输出整个配置文件的键名
echo "config file all key: "
echo ${!dic[*]}
# 输出整个配置文件的键值
echo "config file all val: "
echo ${dic[*]}
# 输出整个配置某个的键值
echo "config file key k8s-worker-7 's val is: "
if [ ${dic["VM_PATH"]} ] ; then
    echo ${dic["VM_PATH"]}
fi
ouput-config-key-val-for-debug

#echo ${dic["VMs_PATH"]} #在shell script中声明变量取值时带双引号，输出取值时不带双引号，正常。

# 帮助信息
THIS_FILE_PATH=$(cd `dirname $0`; pwd)
USAGE_MSG_PATH=${THIS_FILE_PATH}/help
USAGE_MSG_FILE=${USAGE_MSG_PATH}/create-one.txt
# 参数规则
GETOPT_ARGS_SHORT_RULE="--options h,f::,d"
GETOPT_ARGS_LONG_RULE="--long help,file::,debug"

# 设置参数规则
GETOPT_ARGS=`getopt $GETOPT_ARGS_SHORT_RULE \
$GETOPT_ARGS_LONG_RULE -- "$@"`
# 解析参数规则
eval set -- "$GETOPT_ARGS"
# 更新新的配置
CUSTOM_CONFIG_FILE=
while [ -n "$1" ]
do
    case $1 in
    -f|--file) #可选，可接可不接参数
    CUSTOM_CONFIG_FILE=$2
    #echo $CUSTOM_CONFIG_FILE 
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

function ouput_debug_msg(){
local debug_msg=$1
local debug_swith=$2
if [[ "$debug_swith" =~ "false" ]] ; 
then 
    echo $debug_msg > /dev/null 2>&1
else
    echo $debug_msg ; 
fi 
}

#内置配置文件名字
BUILT_IN_CONFIG_FILE_NAME=vm-config.default.txt
function read_config_file(){
#echo ${THIS_FILE_PATH}
local CONFIG_FILE=${THIS_FILE_PATH}/${BUILT_IN_CONFIG_FILE_NAME}
if [ -n "${1}" ]
then
    CONFIG_FILE=$1
fi
local test=`sed 's/^ *//g' $CONFIG_FILE | grep --invert-match "^#"`
#字符转为数组
local arr=($test)
local key=
local value=
for i in "${arr[@]}"; do
    # 获取键名
    key=`echo $i|awk -F'=' '{print $1}'`
    # 获取键值
    value=`echo $i|awk -F'=' '{print $2}'`
    # 输出该行
    #printf "%s\t\n" "$i"
    dic+=([$key]=$value)
done
echo "read confifg file:$CONFIG_FILE"
}

#读取内置配置文件
echo "read built-in config:..."
read_config_file
echo "read custom config:..."
#读取自定配置文件
if [[ "$CUSTOM_CONFIG_FILE" =~ "^/" ]] ;
then
    ouput_debug_msg "absolute path"
elif [[ -n $CUSTOM_CONFIG_FILE ]] ;
then
    ouput_debug_msg "relative path"
    CUSTOM_CONFIG_FILE=$(echo $CUSTOM_CONFIG_FILE | sed "s#./##g")
    CUSTOM_CONFIG_FILE=$THIS_FILE_PATH/$CUSTOM_CONFIG_FILE
fi
if [[ -n $CUSTOM_CONFIG_FILE && -e $CUSTOM_CONFIG_FILE ]]
then
    #echo "$CUSTOM_CONFIG_FILE"
    read_config_file $CUSTOM_CONFIG_FILE
fi

:<<ouput-custom-config-key-val-for-debug
# 输出整个配置文件的键名
echo "config file all key: "
echo ${!dic[*]}
# 输出整个配置文件的键值
echo "config file all val: "
echo ${dic[*]}
# 输出整个配置某个的键值
echo "config file key k8s-worker-7 's val is: "
if [ ${dic["VM_PATH"]} ] ; then
    echo ${dic["VM_PATH"]}
fi
ouput-custom-config-key-val-for-debug

#echo ${dic["VMs_PATH"]} #vm-config.txt中声明变量取值时若带双引号，输出取值时则带双引号，路径拼接出错。
#echo ${dic["VMs_PATH"]} #vm-config.txt中声明变量取值时不带双引号，输出取值时不带双引号，路径拼接正常。

# 生成相关变量
#主机列表目录
VMs_PATH=${dic["VMs_PATH"]}
#本虚拟机目录
VM_PATH=${dic["VM_PATH"]}
#路径间隔符号
PATH_SPLIT_SYMBOL=${dic["PATH_SPLIT_SYMBOL"]}
#系统类型
OS_TYPE=${dic["OS_TYPE"]}
OS_ID=${dic["OS_ID"]}
#内存大小
MEMORY_SIZE=${dic["MEMORY_SIZE"]}
#硬盘大小
DISK_SIZE=${dic["DISK_SIZE"]}
#硬盘类型
DISK_TYPE=${dic["DISK_TYPE"]}
#存储控制器IDE
STORAGE_CONTROLLER_IDE_NAME=${dic["STORAGE_CONTROLLER_IDE_NAME"]}
STORAGE_CONTROLLER_IDE_TYPE=${dic["STORAGE_CONTROLLER_IDE_TYPE"]}
#存储控制器SATA
STORAGE_CONTROLLER_SATA_NAME=${dic["STORAGE_CONTROLLER_SATA_NAME"]}
STORAGE_CONTROLLER_SATA_TYPE=${dic["STORAGE_CONTROLLER_SATA_TYPE"]}
#镜像文件
OS_ISO_NAME=${dic["OS_ISO_NAME"]}
#线程数量
CPU_PROCESOOR_NUMBER=${dic["CPU_PROCESOOR_NUMBER"]}
# 屏幕控制
DISPLAY_GRAPHICIS_CONTROLLER=${dic["DISPLAY_GRAPHICIS_CONTROLLER"]}

# 生成临时变量
#基础目录
VM_BASE_PATH=${VMs_PATH}${PATH_SPLIT_SYMBOL}${VM_PATH}
#主机名字
VM_NAME=$VM_PATH
#硬盘路径
DISK_PATH=${VMs_PATH}${PATH_SPLIT_SYMBOL}${VM_NAME}${PATH_SPLIT_SYMBOL}
#硬盘名字
DISK_NAME=$VM_NAME
#硬盘文件
DISK_FILE=${DISK_PATH}${DISK_NAME}${DISK_TYPE}

#echo $VM_PATH,$VM_BASE_PATH,$OS_ISO_NAME

# 创建相关目录
mkdir -p $VMs_PATH
cd $VMs_PATH
mkdir -p $VM_PATH
cd $VM_PATH

#创建某虚拟机
#2 查看支持的系统类型
declare -A OS_TYPE_SUPPORT_LIST
OS_TYPE_SUPPORT_LIST=()
for val in `vboxmanage list ostypes | grep "Family ID:" |sed "s/Family ID: *//g" `
do
    if [[ ${OS_TYPE_SUPPORT_LIST[${val}]} != "1" ]] ; 
    then 
        OS_TYPE_SUPPORT_LIST[${val}]="1"
    fi
done
echo "os type virtualbox solft supports: ${!OS_TYPE_SUPPORT_LIST[@]}"
echo "now uses: $OS_TYPE"


#2 查看支持的系统版本
declare -A OS_VERSION_SUPPORT_LIST
OS_VERSION_SUPPORT_LIST=()
for val in `vboxmanage list ostypes | grep -C 5 "Family ID:   $OS_TYPE" | grep --invert-match "Family ID:" | grep "ID:" |sed "s/ID: *//g" `
do
    if [[ ${OS_VERSION_SUPPORT_LIST[${val}]} != "1" ]] ; 
    then 
        OS_VERSION_SUPPORT_LIST[${val}]="1"
    fi
done
echo "os version for $OS_TYPE is: ${!OS_VERSION_SUPPORT_LIST[@]}"
echo "now uses: $OS_ID"

# 创建硬盘
vboxmanage createmedium disk --filename $DISK_NAME --size $DISK_SIZE
# 修改硬盘
#vboxmanage modifymedium disk $DISK_NAME --resize $DISK_SIZE
# 创建虚机
vboxmanage createvm --name $VM_NAME --ostype $OS_ID --register --basefolder $VMs_PATH
# 删除虚机
#VBoxManage unregistervm $VM_NAME --delete
# 设置内存
VBoxManage modifyvm $VM_NAME --memory $MEMORY_SIZE

VRAM_SIZE=16 #`expr 16 \* 1024` 
#echo $VRAM_SIZE
VBoxManage modifyvm $VM_NAME --vram $VRAM_SIZE

# 设处理器
#设置内核数量
VBoxManage modifyvm $VM_NAME  --ioapic on
VBoxManage modifyvm $VM_NAME --cpus $CPU_PROCESOOR_NUMBER
#设置运行峰值
VBoxManage modifyvm $VM_NAME --cpuexecutioncap 80

# 设置显示
VBoxManage modifyvm $VM_NAME --graphicscontroller $DISPLAY_GRAPHICIS_CONTROLLER

# 设置存储
#2 建存储控制器
VBoxManage storagectl $VM_NAME --name $STORAGE_CONTROLLER_SATA_NAME --add sata --controller $STORAGE_CONTROLLER_SATA_TYPE --bootable on --portcount 1
VBoxManage storagectl $VM_NAME --name $STORAGE_CONTROLLER_IDE_NAME --add ide --controller $STORAGE_CONTROLLER_IDE_TYPE --bootable on
#2 删存储控制器
#VBoxManage storagectl $VM_NAME --name $STORAGE_CONTROLLER_SATA_NAME --remove 
#VBoxManage storagectl $VM_NAME --name $STORAGE_CONTROLLER_IDE_NAME --remove 
#2 关联相关镜像
#3 挂载硬盘
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_SATA_NAME --port 0 --device 0 --type hdd --medium $DISK_FILE
#3 挂载光驱
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 1 --device 0 --type dvddrive --medium $OS_ISO_NAME
#2 删除相关镜像
#3 卸载硬盘
#VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_SATA_NAME --port 0 --device 0 --type hdd --medium none
#3 卸载光驱
#VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 1 --device 0 --type dvddrive --medium none

# 设启动项
vboxmanage modifyvm $VM_NAME --ioapic on
vboxmanage modifyvm $VM_NAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

# 设置网络

# 查看帮助
#vboxmanage --help > dev/log/vboxmanage-help.txt
# 查看虚机
:<<get-vm-detail
VBoxManage -v
VBoxManage list vms
VBoxManage list runningvms
VBoxManage showvminfo master
VBoxManage list hdds
VBoxManage list dvds
VBoxManage list usbfilters
vm_name=centos-7.6
VBoxManage showvminfo $vm_name > log/vm-${vm_name}-detail.txt
get-vm-detail
# 启动虚机
VBoxManage startvm $VM_NAME --type headless #[--type gui|sdl|headless|separate]
# 关闭虚机
#关机方式
#CLOSE_VM_WAY=
#VBoxManage controlvm $VM_NAME savestate
#VBoxManage discardstate $VM_NAME
#VBoxManage controlvm $VM_NAME poweroff
# 迁移虚机
# VBoxManage movevm $VM_NAME
# 克隆虚机

#### 参考文献
:<<reference 
VirtualBox命令行VBoxManage创建与管理虚拟机教程
https://www.jianshu.com/p/a2d4840341fb
VBoxManage命令用法详解
https://www.cnblogs.com/readleafblackrain/articles/3974882.html
linux命令行下使用vboxmanage安装linux系统
https://www.cnblogs.com/liuxuzzz/p/5313835.html
VBoxManage 命令行安装虚拟机
https://blog.csdn.net/u012423685/article/details/89927450

Vagrant之创建一个基于CentOS的Vagrant Base Box
http://ju.outofmemory.cn/entry/162226
How to Create a CentOS Vagrant Base Box
https://github.com/ckan/ckan/wiki/How-to-Create-a-CentOS-Vagrant-Base-Box
用 vagrant 快速部署 docker 虚拟机集群
https://blog.csdn.net/pmlpml/article/details/53925542

Virtualbox和主机共享粘贴板
https://blog.csdn.net/baidu_37503452/article/details/78707806
VirtualBox安装CentOS实现鼠标自动切换和复制粘贴功能
https://www.jb51.net/article/105374.htm
Virtualbox主机和虚拟机之间文件夹共享及双向拷贝
https://www.jb51.net/article/97271.htm
Virtual Box 工具栏（菜单栏）消失的解决方法(gui)
https://blog.csdn.net/weixin_33835690/article/details/94175692
VirtualBox增强功能包安装方法(gui)
https://jingyan.baidu.com/article/9f63fb918bfcc1c8400f0e12.html

VirtualBox与VMware中的网络模式详解
https://blog.csdn.net/Akeron/article/details/78543672
VirtualBox6.0中CentOS7.6 网络配置
https://my.oschina.net/gwlCode/blog/3014144
VirtualBox的Nat模式设置及端口映射（gui）
VBoxManage命令用法详解
https://www.cnblogs.com/readleafblackrain/articles/3974882.html
在Windows使用VirtualBox搭建CentOS7服务器(gui)
https://blog.csdn.net/tavisdxh/article/details/88924670
reference

