
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

#主机列表目录
VMs_PATH="D:\\VirtualBox\\Administrator\\VMs"
mkdir -p $VMs_PATH
cd $VMs_PATH
echo $VMs_PATH
#本虚拟机目录
VM_PATH=centos-7.6
mkdir -p $VM_PATH
cd $VM_PATH
PATH_SPLIT_SYMBOL="\\"
#本机基础目录
VM_BASE_PATH=${VMs_PATH}${PATH_SPLIT_SYMBOL}${VM_PATH}
echo $VM_BASE_PATH


#
#主机名字
VM_NAME=$VM_PATH
#系统类型
OS_TYPE=Linux #Linux|MacOS|Windows
OS_ID=RedHat_64 #
#内存大小
MEMORY_SIZE=4096 #单位：M
#硬盘大小
DISK_SIZE=20000 #单位：M
#硬盘路径
DISK_PATH=${VMs_PATH}${PATH_SPLIT_SYMBOL}${VM_NAME}${PATH_SPLIT_SYMBOL}
#硬盘类型
DISK_TYPE=.vdi
#硬盘名字
DISK_NAME=$VM_NAME
#硬盘文件
DISK_FILE=${DISK_PATH}${DISK_NAME}${DISK_TYPE}
#存储控制器IDE
STORAGE_CONTROLLER_IDE_NAME=IDE
STORAGE_CONTROLLER_IDE_TYPE=PIIX4
#存储控制器SATA
STORAGE_CONTROLLER_SATA_NAME=SATA
STORAGE_CONTROLLER_SATA_TYPE=IntelAhci
#镜像文件
OS_ISO_NAME="D:\\some-important-soflt\\CentOS-7-x86_64-DVD-1908.iso"
#线程数量
CPU_PROCESOOR_NUMBER=2
# 屏幕控制
DISPLAY_GRAPHICIS_CONTROLLER=VBoxVGA #none|vboxvga|vmsvga|vboxsvga

# 创建硬盘
vboxmanage createmedium disk --filename $DISK_NAME --size $DISK_SIZE
# 修改硬盘
#vboxmanage modifymedium disk $DISK_NAME --resize $DISK_SIZE

#创建某虚拟机
#2 查看支持的系统类型
vboxmanage list ostypes | grep "Family ID:"
#2 查看支持的系统版本
vboxmanage list ostypes | grep -C 5 "Family ID:   $OS_TYPE" | grep --invert-match "Family ID:" | grep "ID:"
vboxmanage createvm --name $VM_NAME --ostype $OS_ID --register --basefolder $VMs_PATH
#--basefolder
:<<or-run-as-below
#2 查看支持的系统类型
vboxmanage list ostypes | grep "Family ID:"
#2 查看支持的系统版本
vboxmanage list ostypes | grep -C 5 "Family ID:   $OS_TYPE" | grep --invert-match "Family ID:" | grep "ID:"
VBoxManage createvm --name $VM_NAME --register --basefolder $VMs_PATH
VBoxManage modifyvm $VM_NAME --ostype $OS_ID
or-run-as-below
#删除某虚拟机
#VBoxManage unregistervm $VM_NAME --delete

# 设置内存
VBoxManage modifyvm $VM_NAME --memory $MEMORY_SIZE

VRAM_SIZE=16 #`expr 16 \* 1024` 
#echo $VRAM_SIZE
VBoxManage modifyvm $VM_NAME --vram $VRAM_SIZE

#VBoxManage modifyvm $VM_NAME --snapshotfolder "D:\\VirtualBox\\Administrator\\VMs\\${VM_PATH}\\Snapshots"
#VBoxManage controlvm $VM_NAME usbattach --capturefile "D:\VirtualBox\Administrator\VMs\centos-7.6\centos-7.6.webm"
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
#VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 0 --device 0 --type dvddrive --medium "E:\Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso"
:<<case01-is-ok
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 0 --device 0 --type hdd --medium $DISK_FILE
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_SATA_NAME --port 1 --device 0 --type dvddrive --medium $OS_ISO_NAME
case01-is-ok
#3 挂载硬盘
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_SATA_NAME --port 0 --device 0 --type hdd --medium $DISK_FILE
#3 挂载光驱
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 1 --device 0 --type dvddrive --medium $OS_ISO_NAME
#2 删除相关镜像
:<<case01-delete-is-ok
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 0 --device 0 --type dvddrive --medium none
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_SATA_NAME --port 1 --device 0 --type dvddrive --medium none
case01-delete-is-ok

# 设启动项
vboxmanage modifyvm $VM_NAME --ioapic on
vboxmanage modifyvm $VM_NAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

# 设置网络


#查看虚拟主机
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
#启动
VBoxManage startvm $VM_NAME --type headless #[--type gui|sdl|headless|separate]

#关机
#关机方式
#CLOSE_VM_WAY=
#VBoxManage controlvm $VM_NAME savestate
#VBoxManage discardstate $VM_NAME
#VBoxManage controlvm $VM_NAME poweroff

#迁移
# VBoxManage movevm $VM_NAME

#克隆

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

