# yum命令所在包

CentOS

**格式:**

> 包名: 命令名

```json
expect: [
    mkpasswd
],
psmisc: killall,
iproute: [
    ss, 
    ip
],
iputils: [
    ping
],
net-tools: [
    ifconfig,
    netstat
],
bridge-utils: [
    brctl
],
mlocate: [
    updatedb, locate
],
bind-utils: [
    dig
],
crontabs: [
    crontab
],
man-pages: [
    man手册bash命令, 系统调用等内容(不包括man命令本身, man命令需要额外安装)
]
```
