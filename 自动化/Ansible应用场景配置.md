# Ansible应用场景

## 1. SSH部分

## 2. 日志输出

默认ansible 执行的时候，并不会输出日志到文件，不过在ansible.cfg 配置文件中有如下行：

```
# logging is off by default unless this path is defined
# if so defined, consider logrotate
log_path = /var/log/ansible.log
```

同样，默认`log_path`这行是注释的，打开该行的注释，所有的命令执行后，都会将日志输出到`/var/log/ansible.log`文件，便于了解在何时执行了何操作及其结果，如下：

```
[root@361way.com ansible]# cat /var/log/ansible.log
2015-05-04 01:57:19,758 p=4667 u=root |
2015-05-04 01:57:19,759 p=4667 u=root |  /usr/bin/ansible test -a uptime
2015-05-04 01:57:19,759 p=4667 u=root |
2015-05-04 01:57:20,563 p=4667 u=root |  10.212.52.252 | success | rc=0 >>
 01:57am  up 23 days 11:20,  2 users,  load average: 0.38, 0.38, 0.40
2015-05-04 01:57:20,831 p=4667 u=root |  10.212.52.14 | success | rc=0 >>
 02:03am  up 331 days  8:19,  2 users,  load average: 0.08, 0.05, 0.05
2015-05-04 01:57:20,909 p=4667 u=root |  10.212.52.16 | success | rc=0 >>
 02:05am  up 331 days  8:56,  2 users,  load average: 0.00, 0.01, 0.05
```