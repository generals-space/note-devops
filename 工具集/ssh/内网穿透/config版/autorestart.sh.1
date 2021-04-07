#!/bin/bash

is_exist=$(ps ux | grep forward-xcx | grep -v grep | wc -l)
if [ $is_exist -eq 0 ]; then
    ## 主要是这里, 如果只写ssh forward, 不写命令的话, 
    ## crontab在调用此脚本时会执行ssh且能成功, 但会立即终止.
    ## 这不是环境变量的问题, 应该是因为会话中断的问题.
    ## ssh成功的瞬间就脱离了当前的bash session, 所以进程会被终止.
    ## 不过好在可以通过这种执行阻塞命令保持进程存在.
    ssh forward 'tail -f /etc/os-release' >> /tmp/autossh.log 2>&1
fi
