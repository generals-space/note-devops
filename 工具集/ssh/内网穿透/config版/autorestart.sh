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
    echo $1 $2 >> /tmp/ssh.log
    if (( $(get_forward_proc $1 | wc -l) == 0 )); then
        echo 'try to restart...'
        echo try to restart $1 >> /tmp/ssh.log
        ssh -tt $1 &
    else
        ## 即使本地 forward 进程存在, 但中转服务器上仍然可能没有出现转发的端口
        ## 这里我们需要到中转服务器上查看一下, 如果没有映射成功, 则要将本地的转发进程 kill 掉.
        if (( $(get_forward_port $2) == 0 )); then
            echo "$2 is 0" >> /tmp/ssh.log
            pid=$(get_forward_proc $1 | awk '{print $2}')
            kill $pid
        fi
    fi
}

## 移除 known_hosts 中的域名与公钥记录
## 虽然 config 中 StrictHostKeyChecking 配置不检查目标主机的公钥,
## 但是如果已经存在一条公钥记录, 而在新请求中发现目标主机公钥与这个已经存在的公钥不一致时, 还是会报错.
## 注意: 参数n要放在参数i后面, 否则会报错
sed -in '/nat.generals.space/d' ~/.ssh/known_hosts >> /tmp/ssh.log 2>&1
## 注意这里的端口值要与 config 文件中 forward-xxx 中的端口保持一致
keep_alive forward-ssh 10004
keep_alive forward-vnc 10005
