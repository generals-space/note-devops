# iptables-常用匹配规则及示例(转)

参考文章

1. [IPTable简介3——常用匹配](https://www.jianshu.com/p/f0dee39b20ba)

匹配规则可以用`!`号进行非运算

## 1. 常规匹配

### 1.1 通用匹配规则

`-s(--src)`: 对报文源ip地址进行匹配

可以是常规的数字IP地址，也可以是ip网段，如果是ip网段可以用如下方式定义: 

例如: `-s 192.168.1.0/24` 或者 `-s 192.168.1.0/255.255.255.0` 两者等效

`-d(--dst)`: 对目的ip地址进行匹配

此规则和`-s`相同

`-p(--protocol)`: 对ip协议进行匹配

可以是关键字`TCP`、`UDP`或`ICMP`, 也可以是这些协议在IP协议上的协议号（ICMP-1,TCP-6,UDP-7). 

如果是关键字可以在`/etc/protocols`里定义的协议关键字都可以. 还可以是`ALL`, 表示上述三个协议都可以. 

例如: `-p !TCP` 表示匹配协议为非tcp的包. 

## 2. 暗含匹配规则

### 2.1 对tcp和udp协议可以对源端口和目的端口进行匹配

- `-dport`: 对目的端口进行匹配
- `-sport`: 对源端口进行匹配

例如: `-p tcp --dport 8080`

`-p tcp --dport 8080:9000` //匹配tcp 端口从8080---9000的所有端口

`-p udp --sport :90` //匹配源端口从0--90端口的所有包

### 2.2 icmp包类型匹配

- `--icmp-type`: 对icmp包的某个特殊类型进行匹配

例如: `-p icmp --icmp-type 8`

3、详细匹配

所有前述的匹配都是不需要加载特殊模块就可以执行的动作. 但是现在所描述的匹配都是需要显地加载模块才可以支持. 

加载模块的方法用-m或者--match 跟模块名

例如:  -m state

2.1、Addrtype匹配

对报文的地址类型进行匹配. 常见的地址类型有: 

LOCAL:表示地址是本地地址，指本地一切地址含: 127.0.0.1回环地址

UNICAST: 单播地址

MULTICAST: 组播地址

BROADCAST: 广播地址

例如: 

-m addrtype --dst-type LOCAL

-m addrtype --src-type MULTICAST



2.2、 Mac匹配

对包的源mac地址进行匹配

-m mac --mac-source 01: 11: 12: 13: 14: 15

只能对prerouting ,forward, input进行匹配. 

2.3 、Multiport匹配

对多个端口进行匹配. 

-p tcp -m multiport --source-port 22，53，44

-p udp -m multiport --destination-port 11，44，55

-p all -m multi port --port 88,8080

2.4、iprange匹配

对多个ip地址进行匹配

例如: -m iprange --src-range 192.168.3.4-192.168.3.7

-m iprange --dst-range 192.168.3.4-192.168.3.9

2.5、pkttype匹配

可以对ip包的类型进行匹配: unicast，multicast或broadcast

例如: 

-m pktype --pkt-type !broadcast

2.6、physdev匹配

可以对netfilter的接入和发送接口名进行匹配. 这个和iptables自带的-i 和-o不同的是，physdev只针对网桥的接口. 

例如: 

-m physdev --physdev-in eth1 --physdev-out eth0

2.7 length匹配

匹配包长度可以length匹配

例如

-m length --length 1400: 1500

-m length --length 1400

### 2.8、state匹配

netfilter在内核中有链接跟踪模块，能够对链接（面向链接和非面向链接都一样）进行状态跟踪，iptables可以利用链接跟踪模块进行匹配常用的链接跟踪匹配模块有state匹配和下文的conntrack匹配（state匹配的扩展）

链接跟踪模块定义了以下几种状态: 

NEW:当一个ip包被第一次发出以后，防火墙就规定该流向进入了NEW状态. 对应了tcp的sync包发出、udp和icmp的第一个包发出

ESTABLISHED: 当该流向的第一包发出后，得到来自对段的ip包后进入此状态. 对应tcp收到对端的ack（回复sync）或对段sync包，udp收到对段响应包

RELATED: 就是当本流进入established状态后，防火墙识别到本流相关的流就被标记为此状态. 例如: ftp 命令流对应的ftp数据流. 

INVALID

例如: -m state --state RELATED

### 2.9、conntrack匹配

是对state匹配的扩展，常用的是--cstate 它除了有state 匹配的状态，还定义了SNAT DNAT

### 2.10、limit匹配

对于iptables的log动作，可以使用limit匹配来限制记录的数据包频率. 

例如: 

- `-m limit --limit 3/hour`
- `-m limit --limit 4/second`
- `-m limit --limit 10/minute`
- `-m limit --limit 11/day`
