# iptables-set模块与ipset命令应用

参考文章

1. [利用 ipset 封禁大量 IP](https://fixatom.com/block-ip-with-ipset/)
    - ipset命令使用示例
    - ipset的

`ipset`命令可以看作是iptables某种形式上的便携应用, 需要iptables指定`set`模块.

以下命令实现了一个iptables的黑名单机制, 借助ipset而不是长长的iptables命令.

1. `ipset create myset hash:ip`: 创建一个集合set.
2. `iptables -I INPUT -m set --match-set myset src -j DROP`: 使用iptables的set模块创建一个默认为DROP的规则.
3. `ipset add myset 192.168.0.101`: 向myset这个集合中添加ip, 所有这个集合中的ip都会匹配上面第2条的规则.

第2条命令执行后, 可以使用iptables看到相关的规则.

```
$ iptables -nL
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
DROP       all  --  0.0.0.0/0            0.0.0.0/0            match-set myset src
```

但是第3条命令中, 使用`ipset add`向`myset`添加的条目却无法在iptables中查看到, 只能使用`ipset list myset`命令.

```
$ ipset list myset
Name: myset
Type: hash:ip
Revision: 4
Header: family inet hashsize 1024 maxelem 65536
Size in memory: 168
References: 1
Number of entries: 1
Members:
192.168.0.101
```

然后当前主机无法再ping通`192.168.0.101`.

可以使用`ipset del myset 192.168.0.101`从myset中删除一条记录.

------

前面例子中的`myset`这个集合是以 hash 方式存储 IP 地址, 也就是以 IP 地址为 hash 的键. 

除了IP地址, 还可以是网络段, 端口号（支持指定 TCP/UDP 协议）, mac 地址, 网络接口名称, 或者上述各种类型的组合. 

`man ipset`手册可以查看不同存储类型的名称及添加示例.
