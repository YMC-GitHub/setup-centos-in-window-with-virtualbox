
#!/bin/sh

# 使用virtualbox创建虚拟主机
# 通过VBoxManage使用virtualbox的cli的方式
# 需要：
# 创建某虚拟机
# 设置系统类型
# 设置内存大小
# 建立虚拟磁盘
# 建存储控制器
# 关联虚机磁盘
# 关联镜像文件
# 设置网络连接
# 设置远程桌面
# 设置内核数量

# 注：win 系统下以管理员身份运行git-bash，在其窗口下运行此脚本

#主机目录
VMs_PATH="D:\\VirtualBox\\Administrator\\VMs"
echo $VMs_PATH
VM_PATH=centos-7.6
mkdir -p $VM_PATH
cd $VM_PATH
PATH_SPLIT_SYMBOL="\\"
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

#创建虚机
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
#删除虚机
VBoxManage unregistervm $VM_NAME --delete

# 设置内存
VBoxManage modifyvm $VM_NAME --memory $MEMORY_SIZE

VRAM_SIZE=16 #`expr 16 \* 1024` 
echo $VRAM_SIZE
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
VBoxManage storagectl $VM_NAME --name $STORAGE_CONTROLLER_SATA_NAME --remove 
VBoxManage storagectl $VM_NAME --name $STORAGE_CONTROLLER_IDE_NAME --remove 


#
# 关联镜像
#VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 0 --device 0 --type dvddrive --medium "E:\Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso"
:<<case01-is-ok
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 0 --device 0 --type hdd --medium $DISK_FILE
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_SATA_NAME --port 1 --device 0 --type dvddrive --medium $OS_ISO_NAME
case01-is-ok
#2 挂载硬盘
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_SATA_NAME --port 0 --device 0 --type hdd --medium $DISK_FILE
#2 挂载光驱
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 1 --device 0 --type dvddrive --medium $OS_ISO_NAME
# 删除镜像
:<<case01-delete-is-ok
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_IDE_NAME --port 0 --device 0 --type dvddrive --medium none
VBoxManage storageattach $VM_NAME --storagectl $STORAGE_CONTROLLER_SATA_NAME --port 1 --device 0 --type dvddrive --medium none
case01-delete-is-ok
# 设启动项
vboxmanage modifyvm $VM_NAME --ioapic on
vboxmanage modifyvm $VM_NAME --boot1 dvd --boot2 disk --boot3 none --boot4 none


#挂载硬盘--将win2008.vdi文件作为虚拟机win2008的第一块IDE硬盘
#VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium win2008.vdi
#挂载光盘--
#配置第一个IDE光驱，并挂载安装光盘
#VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium server_2008_64.iso


# 设置网络
#2 查看网卡（win）
# netsh interface ipv4 show subinterfaces
#2 查看网卡（linux）
# ifconfig
#2 设置桥接
NIC_NUMBER=1 #网卡序号
NET_TYPE=bridged #网络类型
BRIDGE_ADAPTER_NUMBER=1 #网桥适配器序号
PM_NIC_NAME=e1000g0
$(vboxmanage modifyvm $VM_NAME --nic${NIC_NUMBER} $NET_TYPE --bridgeadapter${BRIDGE_ADAPTER_NUMBER} $PM_NIC_NAME)
:<<set-vm-network
# 将虚拟机$VM_NAME的第一个网卡的网络连接方式设为桥接
VBoxManage modifyvm $VM_NAME --nic1 bridged

# 将虚拟机$VM_NAME的第一个网卡的网卡芯片类型设为82540EM
VBoxManage modifyvm $VM_NAME --nictype1 82540EM

# 将虚拟机$VM_NAME的第一个网卡桥接到物理机的eth0网卡上
VBoxManage modifyvm $VM_NAME --bridgeadapter1 eth0
set-vm-network

:<<set-share-dir-for-vm

# 创建共享目录
# 将物理机的$PM_SHARE_DIR目录共享给虚拟机$VM_NAME，且共享名为$PM_SHARE_NAME
PM_SHARE_DIR=/home/vbox
PM_SHARE_NAME=share
#2 永久
VBoxManage sharedfolder add $VM_NAME --name $PM_SHARE_NAME --hostpath $PM_SHARE_DIR
#2 瞬间
VBoxManage sharedfolder add $VM_NAME --name $PM_SHARE_NAME --hostpath $PM_SHARE_DIR --transient
set-share-dir-for-vm

#设置远程桌面
VBoxManage modifyvm $VM_NAME --vrdeport 5540 --vrdeaddress ""
#打开远程桌面
VBoxManage modifyvm $VM_NAME --vrde on
#关闭远程桌面

# 设置其他
VBoxManage modifyvm $VM_NAME --rtcuseutc on
VBoxManage modifyvm $VM_NAME --clipboard bidirectional
VBoxManage modifyvm $VM_NAME --draganddrop bidirectional
VBoxManage modifyvm $VM_NAME --usbohci on

#查看虚拟主机
VBoxManage -v
VBoxManage list vms
VBoxManage list runningvms
VBoxManage showvminfo master
VBoxManage list hdds
VBoxManage list dvds
VBoxManage list usbfilters
vm_name=centos-7.6
VBoxManage showvminfo $vm_name > log/vm-${vm_name}-detail.txt
#启动
VBoxManage startvm $VM_NAME --type headless #[--type gui|sdl|headless|separate]

#关闭
#关闭方式
CLOSE_VM_WAY=
VBoxManage controlvm $VM_NAME savestate
VBoxManage discardstate $VM_NAME
VBoxManage controlvm $VM_NAME poweroff

#迁移
VBoxManage movevm $VM_NAME


##########
#管扩展包
##########
EXT_PACK_NAME=
#安装
VBoxManage extpack install $EXT_PACK_NAME
#卸载
VBoxManage extpack uninstall <name>
#查看
VBoxManage list extpacks
#移除
VBoxManage extpack cleanup



#关闭selinux
#网卡自动开启
#安装wget
:<<install-wget-on-centos
yum install wget
install-wget-on-centos
#更改镜像源
:<<use-aliyun-yum-repos-on-centos
wget -O /etc/yum.repos.d/CentOS-aliyun.repo http://mirrors.aliyun.com/repo/Centos-6.repo
yum clean all
yum makecache
yum update
use-aliyun-yum-repos-on-centos
#安装vim
:<<install-vim-on-centos
yum install vim
install-vim-on-centos
#安装ssh
:<<install-ssh-on-centos
yum install openssh-server
service sshd start 
chkconfig sshd on
install-ssh-on-centos
#安装库
:<<install-some-lib-on-centos
yum install nano gcc bzip2 make kernel-devel-`uname -r` perl
install-some-lib-on-centos
#更改hostname
:<<set-hostname-on-centos
vi /etc/hosts

vi /etc/sysconfig/network
set-hostname-on-centos
#添加用户组admin与用户vagrant
:<<add-user-and-group-on-centos
useradd vagrant
passwd vagrant
groupadd admin
usermod -G admin vagrant
add-user-and-group-on-centos
#更改sudoers file,实现非root用户vagrant sudo后不需要密码
:<<update-sudoers-on-centos
#设置
cat >> XXX <<EOF
#Add SSH_AUTH_SOCK to the env_keep option
#Comment out the Defaults requiretty line
#Add the line %admin ALL=NOPASSWD: ALL
# visudo
Defaults    env_keep += SSH_AUTH_SOCK
# 在root    ALL=(ALL)       ALL下
root    ALL=(ALL)       ALL
%admin  ALL=(ALL) NOPASSWD:   ALL
Defaults:vagrant !requiretty
EOF
# 检查
su vagrant
sudo ls
update-sudoers-on-centos
#vagrant用户有执行ssh的权限
:<<set-ssh-auth-for-a-user-on-centos
mkdir .ssh
curl -k https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub > .ssh/authorized_keys
chmod 0700 .ssh
chmod 0600 .ssh/authorized_keys
set-ssh-auth-for-a-user-on-centos


#vagrant创建box
# 在物理机上进行
::<<vagrant-create-vbox-on-pm-win
VM_NAME=centos65-x64
VM_PATH=
#关闭虚拟机
#实现宿主机到虚拟机的端口转发
VBoxManage modifyvm $VM_NAME --natpf1 "guestssh,tcp,,2222,,22"
#创建box
VBOX_FILE=centos65-x64.box
cd $VM_PATH
vagrant package --output $VBOX_FILE --base $VM_NAME
vagrant-create-vbox-on-pm-win


#### 参考文献
:<<reference 
VirtualBox命令行VBoxManage创建与管理虚拟机教程
https://www.jianshu.com/p/a2d4840341fb
VBoxManage命令用法详解
https://www.cnblogs.com/readleafblackrain/articles/3974882.html
linux命令行下使用vboxmanage安装linux系统
https://www.cnblogs.com/liuxuzzz/p/5313835.html
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
reference

