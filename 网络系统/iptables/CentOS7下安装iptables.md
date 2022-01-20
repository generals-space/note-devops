# CentOS7下安装iptables

CentOS7下的防火墙默认是`firewalld`, 可能没有安装`iptables`, 使用`iptables`管理网络需要先停止`firewalld`服务, 启动`iptables`服务.

```console
$ ps aux | grep firewalld
root      16286  9.2  2.3 323580 23308 ?        Ssl  22:59   0:01 /usr/bin/python -Es /usr/sbin/firewalld --nofork --nopid
root      16744  0.0  0.0 112644   952 pts/10   R+   22:59   0:00 grep --color=auto firewalld
```

```
systemctl stop firewalld
yum install iptables
systemctl start iptables
```

需要注意的一点是, iptables的`save`命令依然需要通过`service`管理, 使用如下命令都的错误的.

```
systemctl save iptables
systemctl iptables save
```
