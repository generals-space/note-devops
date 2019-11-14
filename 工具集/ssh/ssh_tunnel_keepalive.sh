#!/bin/bash

source ~/Code/bash-libs/libs/logger.sh

: '
## crontab设置
* * * * * source ~/.ssh/ssh_tunnel_keepalive.sh && check_ssh_proc
*/2 * * * * source ~/.ssh/ssh_tunnel_keepalive.sh && check_ssh_tunnel
'

remote_addr=192.168.7.13
remote_port=2222
remote_user=root
local_user=jiangming
map_option="${remote_port}:127.0.0.1:22"
log_file=/tmp/ssh_tun.log

## @function: 检测ssh隧道进程是否存在
## @return:   无返回值
function check_ssh_proc()
{
    local alive=$(ps -ef | grep ssh | grep $map_option | grep -v grep | wc -l)
    if (( alive == 0 )); then
        log_warn 'try to reconnect ssh channel...' >> $log_file
        ssh -y -NTf -R $map_option $remote_user@$remote_addr
    else
        log_info 'ssh channel is still alive...' >> $log_file
    fi
}

## @function: 通过建立的ssh隧道执行一个简单命令, 以检测该隧道是否可用.
function check_ssh_tunnel()
{
    ## 注意这里的用户名为 local_user, 因为这其实是通过中转服务器绕了一圈连公司电脑本身的ssh的.
    ## StrictHostKeyChecking no 默认接受自己的公钥.
    ## 需要 ssh 服务端 GatewayPorts 字段设置为 yes, 否则映射在中转服务器上的端口只监听在127.0.0.1.
    ssh -o 'StrictHostKeyChecking no' $local_user@$remote_addr -p $remote_port ls
    local result = $?
    if (( result != 0 )); then
        log_warn 'the channel is invalid, try to kill it' >> $log_file
        ## 如果无法执行ssh命令, 说明隧道已经无效, 则kill所有ssh隧道进程, 等待重启
        kill $(ps -ef | grep ssh | grep $map_option | grep -v grep | awk '{print $2}')
    fi
}
