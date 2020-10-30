#!/bin/bash

## @function:   判断本机上 forward 进程是否存在
## $1:          转发进程名, 一般为 forward-XXX
## @return:     符合 $1 进程名的 ps 信息.
## @note:       结果以 echo 形式返回
function get_forward_proc
{
    ps ux | grep -v grep | grep $1
}

## @function:   判断中转服务器上映射端口是否存在
## $1:          目标端口值
## @return:     >=0 的整数
## @note:       结果以 echo 形式返回
function get_forward_port
{
    ## forwarder 中转机的配置名称, 需要能无密码登录
    ## 2>&1 的原因: 在普通用户下调用 netstat, 会出现如下警告
    ## (No info could be read for "-p": geteuid()=1001 but you should be root.)
    ssh forwarder "netstat -anp 2>&1 | grep -v grep | grep $1 | wc -l"
}

## @function:   保持转发进程的存在
## $1:          转发进程名, 一般为 forward-XXX
## $2:          映射端口号
## @note:       无返回值
function keep_alive
{
    if (( $(get_forward_proc $1 | wc -l) == 0 )); then
        echo 'try to restart...'
        ssh -tt $1 &
    else
        ## 即使本地 forward 进程存在, 但中转服务器上仍然可能没有出现转发的端口
        ## 这里我们需要到中转服务器上查看一下, 如果没有映射成功, 则要将本地的转发进程 kill 掉.
        if (( $(get_forward_port $2) == 0 )); then
            pid=$(get_forward_proc $1 | awk '{print $2}')
            kill $pid
        fi
    fi
}

keep_alive forward-ssh 10006
keep_alive forward-vnc 10007
