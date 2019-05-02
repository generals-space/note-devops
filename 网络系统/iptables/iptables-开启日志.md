# iptables-开启日志

参考文章

1. [iptables日志探秘](https://my.oschina.net/chenguang/blog/362054)

2. [iptables日志探秘](http://www.cnblogs.com/AloneSword/p/4193419.html)

3. [iptables之LOG目标](http://blog.163.com/leekwen@126/blog/static/33166229200973105543171/)

## 1. 使用方法

核心命令

```
$ iptables -I INPUT -p tcp -m tcp --dport 22 -j LOG --log-prefix 'SSH Connection: '
```

其中核心的核心是`-j LOG`操作. LOG与`ACCEPT`, `REJECT`同级, 但不会是数据包的终点. 意思就是, 经由LOG处理后, 数据包会继续向下匹配其他规则.

日志默认将会输出到`/var/log/messages`文件中. 格式如下

```
Jun 29 08:14:20 localhost kernel: SSH Connection: IN=eno16777736 OUT= MAC=00:0c:29:7b:d7:f2:00:50:56:c0:00:08:08:00 SRC=172.32.100.1 DST=172.32.100.100 LEN=40 TOS=0x00 PREC=0x00 TTL=128 ID=6069 DF PROTO=TCP SPT=50998 DPT=22 WINDOW=259 RES=0x00 ACK URGP=0
```

可以看到`--log-prefix`前缀的作用. 

| 序号  | 字段名称                                    | 含义                                                        |
|-----|-----------------------------------------|-----------------------------------------------------------|
| 1   | Jun 19 17:20:24                         | 日期时间，由syslog生成                                            |
| 2   | Web                                     | 主机名称                                                      |
| 3   | Kernel                                  | 进程名由syslogd生成kernel为内核产生的日志说明netfilter在内核中运行              |
| 4   | `NEW_DRAP`                              | 记录前缀，由用户指定—log-prefix”NEW_DRAP”                           |
| 5   | IN=eth0                                 | 数据包进入的接口，若为空表示本机产生，接口还有eth0、br0等                          |
| 6   | OUT=                                    | 数据包离开的接口，若为空表示本机接收                                        |
| 7   | MAC=00:10:4b:cd:7b:b4:00:e0:le:b9:04:al | `00:10:4b:cd:7b:b4` 为目标MAC地址, `00:e0:le:b9:04:al` 为源MAC地址 |
| 8   | 08:00                                   | 08:00 为上层协议代码，即表示IP协议                                     |
| 9   | SRC=192.168.150.1                       | 192.168.150.1为源IP地址                                       |
| 10  | DST=192.168.150.152                     | 192.168.150.152w为目标IP地址                                   |
| 11  | LEN=20                                  | IP封包+承载数据的总长度(MTU)                                        |
| 12  | TOS=0x00                                | IP包头内的服务类型字段，能反应服务质量包括延迟、可靠性和拥塞等                          |
| 13  | PREC=0x00                               | 服务类型的优先级字段                                                |
| 14  | TTL=249                                 | IP数据包的生存时间                                                |
| 15  | ID=10492                                | IP数据包标示                                                   |
| 16  | DF                                      | DF表示不分段,此字段还可能为MF/FRAG                                    |
| 17  | PROTO=UDP                               | 传输层协议类型，它代表上层协议是什么可分为TCP、UDP、ICMP等                        |
| 18  | SPT=53                                  | 表示源端口号                                                    |
| 19  | DPT=32926                               | 表示目的端口号                                                   |
| 20  | LEN=231                                 | 传输层协议头长度                                                  |
| 21  | SEQ= 内容略                                | TCP序列号                                                    |
| 22  | ACK=内容略                                 | TCP应答号                                                    |
| 23  | WINDOWS=内容略                             | IP包头内的窗口大小                                                |
| 24  | RES                                     | TCP-Flags中ECN bits的值                                      |
| 25  | CWR/ECE/URG/ACK/PSH/RST/SYN/FIN         | TCP标志位                                                    |
| 26  | URGP=                                   | 紧急指针起点                                                    |
| 27  | OPT( 内容略 )                              | IP或TCP选项，括号内为十六进制                                         |
| 28  | INCOMPLETE[65535 bytes]                 | 不完整的数据包                                                   |
| 29  | TYPE=CODE=ID=SEQ=PARAMETER=             | 当协议为ICMP时出现                                               |
| 30  | SPI=0xF1234567                          | 当前协议为AHESP时出现                                             |
| 31  | SYN                                     | TCP-Flags中的SYN标志,此外还有FIN/ACK/RST/URG/PSH几种                |
| 32  | [  ]                                    | 中括号出现在两个地方，在ICMP协议中作为协议头的递归使用；在数据包长度出现非法时用于指出数据实际长度       |


参考文章1, 2(其实是同一篇)中有提到几个iptables日志分析工具, 值得一看.

## 更详尽的配置

### 自定义日志文件路径

`--log-level n`设置日志级别, 注意这个级别不是内容层面, 而是iptables可以连接`rsyslog`服务, 可以进行自定义文件存储. 查看`/etc/rsyslog.conf`.

```
...
# Save boot messages also to boot.log
local7.*                                                /var/log/boot.log
...
```

可以在`iptables`命令中加入`--log-level 5`, 然后在`/etc/rsyslog.conf`添加

```
local5.*                                                /var/log/iptables.log
```

然后重启`rsyslog`服务.

### 

```
[root@localhost ~]# iptables -I INPUT  -p tcp -m tcp ! --dport 22 -j LOG --log-prefix 'Catching'
[root@localhost ~]# iptables -nL
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
LOG        tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:!22 LOG flags 0 level 4 prefix "Catching"
```

> 非22端口用叹号`!`