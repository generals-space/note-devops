# iptables-set模块与ipset命令应用

参考文章

1. [利用 ipset 封禁大量 IP](https://fixatom.com/block-ip-with-ipset/)
    - ipset命令使用示例
    - ipset的
2. [Advanced Firewall Configurations with ipset](https://www.linuxjournal.com/content/advanced-firewall-configurations-ipset)
    - `ipset`是iptables的扩展, 可以说是更强大的匹配器(应该是对比于iptables原本的`dst`, `src`, `iprange`等吧)

`ipset`命令可以看作是iptables某种形式上的便携应用, 需要iptables指定`set`模块, 一般用于实现一个长长列表的黑名单屏蔽.

> 实际上`ipset`是`iptables`的扩展, 可以通过`man iptables-extensions`查看`--match-set`的使用方法.

以下命令实现了一个黑名单, 借助ipset而不是长长的iptables命令.

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


## 删除指定ipset集合

如果`myset`已经通过iptables挂载(上面的第2条命令), 那么在删除时会出现如下报错.

```
$ ipset destroy myset
ipset v7.1: Set cannot be destroyed: it is in use by a kernel component
```

需要先把iptables中使用该集合的规则移除才可以.
