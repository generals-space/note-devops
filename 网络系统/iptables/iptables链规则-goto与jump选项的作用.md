# iptables链规则-goto与jump选项的作用

参考文章

1. [iptables中-j选项与-g选项的区别](http://blog.csdn.net/zahuopuboss/article/details/8886612)

2. [[网络管理] iptables -g 选项？](http://bbs.chinaunix.net/thread-1928388-1-1.html)

iptables中可以通过自定义子链完成更灵活, 管理更方便的操作. 在创建新链后, 需要挂载子链才能让规则生效. iptables下有两个可以将当前匹配规则的数据包交由子链处理, 它们分别是`-g(goto)`与`-j(jump)`.

`-j`参数大多数人都不会陌生, 因为处理动作就是由这个参数指定的, 如`ACCEPT`, `REJECT`, `DROP`等. 它也可以指定一个子链名称, 表示将匹配的规则转交给目标子链.

`-g`用得就少了, 很多人都不明白这两者的区别.

当数据包流入子链, 如果匹配到子链中的某一规则还好, 和普通时候的匹配一样. 但是如果依次匹配下来, 子链中没有没有规则被匹配到, 两者的区别就表现出来了.

`-j`指定的子链, 如果没有匹配到, 会回到父链中进行下一条规则的匹配.

`-g`指定的子链, 如果没有匹配到, 就直接按照当前所在主链的默认规则处理了.

验证

首先清空所有表, 所有规则.

```
[root@localhost ~]# iptables -F
[root@localhost ~]# iptables -X
[root@localhost ~]# iptables -Z
[root@localhost ~]# iptables -t nat -F
[root@localhost ~]# iptables -t nat -X
[root@localhost ~]# iptables -t nat -Z
[root@localhost ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination 
```

干净!

然后创建新链, 命名为`block`, 所有的屏蔽规则在这里显式定义. 注意默认规则都是`ACCEPT`.

```
[root@localhost ~]# iptables -N block
[root@localhost ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain block (0 references)
target     prot opt source               destination  
```

定义规则.

首先, 80和8080转交由block子链处理, 之后把80和8080全部屏蔽, 绝不放过. 

然后, 在block中显示屏蔽80端口.

```
[root@localhost ~]# iptables -A INPUT -p tcp -m multiport --dport 80,8080 -j block
[root@localhost ~]# iptables -A INPUT -p tcp -m multiport --dport 80,8080 -j REJECT
[root@localhost ~]# iptables -A block -p tcp -m tcp --dport 80 -j REJECT
```

我们能够猜到, 80端口的数据包流入INPUT, 然后再进入block被显式屏蔽. 8080端口的数据包首先流入INPUT, 再流入block, 但是block中并没有定义8080端口的规则, `-j`指定的block规则遍历完也没找到合适的, 然后又回到了父链INPUT, 继续匹配, 然后被屏蔽...

如果是用`-g block`指定子链, 结果会有不同吗?

答案是, 会.

为了完成实验, 你需要先删掉`-j block`所在规则, 然后使用`-I`将新规则插入到`-j REJECT`规则之前.

```
[root@localhost ~]# iptables -D INPUT -p tcp -m multiport --dport 80,8080 -j block
[root@localhost ~]# iptables -I INPUT -p tcp -m multiport --dport 80,8080 -g block
```

我们重新梳理一下匹配流程. 80端口因为能在block子链中匹配, 所以不再考虑. 8080依然由INPUT进入block, 依然没有被匹配到, 但是, 8080可以被其它主机访问到. 

为什么?

因为8080接下来没有回到父链级别继续匹配, 而是直接用了其所在主链(INPUT)的规则`ACCEPT`.

两种匹配规则的流程分别如下图.

![](https://gitee.com/generals-space/gitimg/raw/master/a3888a8b776b6ce0ce433afcfe74110d.png)

很多人称`-g/--goto`选项'一去不复返'.

## 再来一例

清空规则

```
[root@localhost ~]# iptables -F
[root@localhost ~]# iptables -X
[root@localhost ~]# iptables -Z
[root@localhost ~]# iptables -t nat -F
[root@localhost ~]# iptables -t nat -X
[root@localhost ~]# iptables -t nat -Z
[root@localhost ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination 
```

设置INPUT默认规则, 创建子链handler, 处理80和8080端口的数据包.

```
[root@localhost ~]# iptables -P INPUT DROP     ## 貌似REJECT不行???
iptables -N handler
iptables -A INPUT -p tcp -m multiport --dport 80,8080 -j handler
```

依然让8080端口数据包无法在子链中完成匹配.

```
iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
iptables -A handler -p tcp -m tcp --dport 80 -j ACCEPT
```

现在handler是以`-j`选项挂到INPUT下的, 可以猜想两者都可以被访问到.

如果是`-g`选项, 那么8080就会被handler丢弃, 直接使用默认规则处理, 因而访问不到了.

图就不画了, 理解就行.
