# iptables链操作

## 1. 修改指定链默认规则

语法: `iptables [-t table名] -P 链名 规则(一般为DROP, ACCEPT等)`

```
iptables -P INPUT DROP
```

## 2. 查看指定链规则

```
iptables [-t {nat|filter}] --list-rules 链名 
```

说明: 不必添加`-L`选项, 可以查看目标链中的规则与子链名称(但不可查看子链下的规则). 若不指定链名, 将打印出当前表中所有规则.

示例

```
$ iptables --list-rules INPUT
-P INPUT ACCEPT
-A INPUT -i virbr0 -p udp -m udp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p udp -m udp --dport 67 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 67 -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -j INPUT_direct
-A INPUT -j INPUT_ZONES_SOURCE
-A INPUT -j INPUT_ZONES
-A INPUT -p icmp -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
```

其中`INPUT_direct`, `INPUT_ZONES_SOURCE`等INPUT的子链哦.

不过貌似子链是没有默认规则的, 只能遵循父链规则. 毕竟子链可能不会是数据包的终点.
