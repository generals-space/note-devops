# iptables-mark模块

参考文章

1. [[网络管理] 关于IPTABLES 各种MARK 功能的用法](http://bbs.chinaunix.net/forum.php?mod=viewthread&tid=1926255)
    - 网卡好多关于mark模块都是引用该帖子的问答.
2. [Iptables数据包、连接标记模块MARK/CONNMARK使用](https://www.haiyun.me/archives/iptables-mark-connmark.html)
    - 查看iptables中有哪些mark相关的模块.
    - mark/MARK与选项`--set-mark`, `--save-mark`, `--restore-mark`的示例.
    - 文章末尾还有一个实例链接, 用iptables做负载均衡的, 不过没看懂...
3. [iptables数据包、连接标记模块MARK/CONNMARK的使用（打标签）](https://www.cnblogs.com/EasonJim/p/8414943.html)
    - 参考文章2的转载者, 但是末尾的说明项是原创的, 值得注意.

## 引言

首先明确, 标记(mark)的目的是匹配, 类似于打标签的目的是为了查询时过滤, 能够方便有效地定位目标.

另外, 标记(mark)的目标有两种: 数据包和连接. 

**数据包**好理解, 在iptables机制中, 一个数据包在进出的过程中要经过很多步骤, 进时为数据包设置标签, 出时匹配标签. 

**连接**的话, 想想在网络编程中, 使用socket创建并建立一个连接, 之后所有的通信都在同一个连接中进行. iptables便是有办法识别同一个连接的数据包, 当然具体原理我还不了解. 

> 注意: `MARK`并没有真正地改动数据包, 它只是在内核空间为包设了一个标记. 防火墙内的其他的规则或程序(如`tc`)可以使用这种标记对包进行过滤或高级路由. 

## 概念

先来看看iptables中与mark相关的模块.

- `-m mark`
- `-m connmark`
- `-j MARK`
- `-j CONNMARK`
- `-j SECMARK`
- `-j CONNSECMARK`

参考文章1中回答者的帖子一针见血:

- 小写的是数据包匹配模块, 大写的是数据包修改模块;
- 带`CONN`的是连接的标记, 不带的是标记数据包的;
- 带`SEC`的是用于处理`IPSEC`数据的, 不带的是处理一般数据的;

大写的MARK还有一些可选选项: 

- `--set-mark(--set-xmark的别名)`: 直接设置连接中的 mark为目标值(注意, 不是设置数据包的)
- `--save-mark`: 把数据包中的 mark 设置到连接中
- `--restore-mark`: 把连接中的 mark 设置到数据包中

参考文章1中有提到可以使用这些选项结合tc实现限流.

## `--set-xmark`选项

选项`--set-xmark value[/mask]`的使用方法值得说明, man手册中对此的解释是: 

```
Zeroes out the bits given by mask and XORs value into the packet mark ("nfmark"). If mask is omitted, 0xFFFFFFFF is assumed.
```

意思是其可以清零当前标记中与`mask`值匹配的位. 再与`value`做异或操作, 结果写入数据包标签. 如果`mask`省略, 则默认为`0xFFFFFFFF`, 即全部清零.

下面两种选项会写入不同的规则.

- `--set-xmark 0x4000`: MARK set 0x4000
- `--set-xmark 0x4000/0x4000`: MARK or 0x4000

由于这种情况, 在`-m mark`匹配时就必须写明是`0x4000`还是`0x4000/0x4000`了, 否则会匹配失败.

