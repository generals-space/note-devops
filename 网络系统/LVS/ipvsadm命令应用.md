# ipvsadm命令应用

`-l/--list`: 查看所有规则.
`-n`: 直接显示端口而不是`http/https`这种名称字符串. 注意这个参数只能放在`-l`的后面, 放在前面会出错.

## 错误方法

```log
$ ipvsadm -nl
Try `ipvsadm -h' or 'ipvsadm --help' for more information.
```

## 正确方法

```log
$ ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.96.0.1:443 rr
  -> 192.168.0.101:6443           Masq    1      0          0
TCP  10.96.0.10:53 rr
TCP  10.96.0.10:9153 rr
UDP  10.96.0.10:53 rr
```

