
#!/bin/sh

#### 一些任务
# 在vm节点上执行
# 任务：
# 更新静态网络地址
# 设置虚机主机名字
# 设置其域名服务器
# ...
###
# 定义内置变量
###
THIS_FILE_PATH=$(
  cd $(dirname $0)
  pwd
)
###
# 定义内置函数
###
function ouput_debug_msg() {
  local debug_msg=$1
  local debug_swith=$2
  if [[ "$debug_swith" =~ "false" ]]; then
    echo $debug_msg >/dev/null 2>&1
  elif [ -n "$debug_swith" ]; then
    echo $debug_msg
  elif [[ "$debug_swith" =~ "true" ]]; then
    echo $debug_msg
  fi
}
function path_resolve_for_relative() {
  local str1="${1}"
  local str2="${2}"
  local slpit_char1=/
  local slpit_char2=/
  if [[ -n ${3} ]]; then
    slpit_char1=${3}
  fi
  if [[ -n ${4} ]]; then
    slpit_char2=${4}
  fi

  # 路径-转为数组
  local arr1=(${str1//$slpit_char1/ })
  local arr2=(${str2//$slpit_char2/ })

  # 路径-解析拼接
  #2 遍历某一数组
  #2 删除元素取值
  #2 获取数组长度
  #2 获取数组下标
  #2 数组元素赋值
  for val2 in ${arr2[@]}; do
    length=${#arr1[@]}
    if [ $val2 = ".." ]; then
      index=$(($length - 1))
      if [ $index -le 0 ]; then index=0; fi
      unset arr1[$index]
      #echo ${arr1[*]}
      #echo  $index
    else
      index=$length
      arr1[$index]=$val2
      #echo ${arr1[*]}
    fi
  done
  # 路径-转为字符
  local str3=''
  for i in ${arr1[@]}; do
    str3=$str3/$i
  done
  if [ -z $str3 ]; then str3="/"; fi
  echo $str3
}
function path_resolve() {
  local str1="${1}"
  local str2="${2}"
  local slpit_char1=/
  local slpit_char2=/
  if [[ -n ${3} ]]; then
    slpit_char1=${3}
  fi
  if [[ -n ${4} ]]; then
    slpit_char2=${4}
  fi

  #FIX:when passed asboult path,dose not return the asboult path itself
  #str2="/d/"
  local str3=""
  str2=$(echo $str2 | sed "s#/\$##")
  ABSOLUTE_PATH_REG_PATTERN="^/"
  if [[ $str2 =~ $ABSOLUTE_PATH_REG_PATTERN ]]; then
    str3=$str2
  else
    str3=$(path_resolve_for_relative $str1 $str2 $slpit_char1 $slpit_char2)
  fi
  echo $str3
}
function get_help_msg() {
  local USAGE_MSG=$1
  local USAGE_MSG_FILE=$2
  if [ -z $USAGE_MSG ]; then
    if [[ -n $USAGE_MSG_FILE && -e $USAGE_MSG_FILE ]]; then
      USAGE_MSG=$(cat $USAGE_MSG_FILE)
    else
      USAGE_MSG="no help msg and file"
    fi
  fi
  echo "$USAGE_MSG"
}
# 引入相关文件
PROJECT_PATH=$(path_resolve $THIS_FILE_PATH "../")
HELP_DIR=$(path_resolve $THIS_FILE_PATH "../help")
SRC_DIR=$(path_resolve $THIS_FILE_PATH "../src")
TEST_DIR=$(path_resolve $THIS_FILE_PATH "../test")
DIST_DIR=$(path_resolve $THIS_FILE_PATH "../dist")
DOCS_DIR=$(path_resolve $THIS_FILE_PATH "../docs")
TOOL_DIR=$(path_resolve $THIS_FILE_PATH "../tool")
# 参数帮助信息
USAGE_MSG=
USAGE_MSG_PATH=$(path_resolve $THIS_FILE_PATH "../help")
USAGE_MSG_FILE=${USAGE_MSG_PATH}/run-some-task-on-vm-node.txt
USAGE_MSG=$(get_help_msg "$USAGE_MSG" "$USAGE_MSG_FILE")
###
#参数规则内容
###
GETOPT_ARGS_SHORT_RULE="--options h,d,"
GETOPT_ARGS_LONG_RULE="--long help,debug,"
###
#设置参数规则
###
GETOPT_ARGS=$(
  getopt $GETOPT_ARGS_SHORT_RULE \
  $GETOPT_ARGS_LONG_RULE -- "$@"
)
###
#解析参数规则
###
eval set -- "$GETOPT_ARGS"
# below generated by write-sources.sh
while [ -n "$1" ]
do
    case $1 in
    -h|--help)
    echo "$USAGE_MSG"
    exit 1
    ;;
    -d|--debug)
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
###
#处理剩余参数
###
# optional
###
#更新内置变量
###
# below generated by write-sources.sh
###
#脚本主要代码
###
$THIS_FILE_PATH/update-net-card-name.sh --new-net-card-name "eth0"
$THIS_FILE_PATH/uses-static-ip.sh --vm-apaddr "192.168.2.9"
$THIS_FILE_PATH/set-host-name.sh --vm-host-name "k8s-node-9"
$THIS_FILE_PATH/sets-dns-resolve.sh --ip-zone "china"
exit 0
