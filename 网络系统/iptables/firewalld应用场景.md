
参考文章

1. [第8章 Iptables与Firewalld防火墙. ](http://www.linuxprobe.com/chapter-08.html?jimmo5550)

2. [How To Migrate from FirewallD to Iptables on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-migrate-from-firewalld-to-iptables-on-centos-7)

## firewalld与iptables的关系

firewalld是Red Hat7版本中默认的防火墙管理工具, 相比于iptables, 它多出了一个`zone`的概念, 包括`trusted`, `home`, `work`等多个应用场景, 用快速切换不同环境下的防火墙规则, 尤其在规则数量极多时更显方便.

...不是我说, 用iptables保存多个配置文件, 不同场景换一个配置然后重启一下服务不就行了, 这优势跟没有一个样.

> 这里有必要说明一下 firewalld 和 iptables 之间的关系,  firewalld 提供了一个 daemon 和 service, 还有命令行和图形界面配置工具, 它**仅仅是替代了 iptables service 部分**, 其底层还是使用 iptables 作为防火墙规则管理入口. firewalld 使用 python 语言开发, 在新版本中已经计划使用 c++ 重写 daemon 部分. 

由于firewalld还是使用iptables的规则管理接口, 所以最终其本身的过滤规则还是会转化成iptables的形式, 可以使用常规的`iptables -L`查看, 或使用`iptables -S`导出. 但反过来就不行, 就算你按照firewalld的修改对iptables带来的变化改写一条新的规则添加进去, firewalld也无法查看. 

我们可以把firewalld服务当成是一个预编译器, 或是程序语言中的语法糖, 它的书写规则更符合人们的思维逻辑. 相当于shell之于java, 它预先定义了许多东西, 虽然不一定很常用, 但应该是Red Hat对iptables应用多年以来的最佳实践. 

其实想想, iptables不过就是开放/屏蔽端口, 允许/阻止来源, 选择通信协议, 地址转换等功能的排列组合, firewalld大致上将每一种功能都抽象成子链的形式, 并且保证转化后不改变数据包的匹配流程, 以达到与iptables直接定义规则实现相同功能的目的.

转化的对应关系与先后顺序应该涉及架构层面的经验, 以我目前的境界无法理解, 暂时先这样吧.

## firewalld的规则定义方式

## 1. zone篇

`--get-zones`: 显示可用的zone, 一般也就是`/usr/lib/firewalld/zones`目录下列出的类型.

```
$ firewall-cmd --get-zones 
block dmz drop external home internal public trusted work
```

`--get-default-zone`: 显示当前所用zone

```
$ firewall-cmd --get-default-zone 
public
```

`--list-all`: 查看当前zone下的规则.

```
$ firewall-cmd --list-all
public (default, active)
  interfaces: eno16777736
  sources: 
  services: dhcpv6-client ssh
  ports: 
  masquerade: no
  forward-ports: 
  icmp-blocks: 
  rich rules: 
```


## 2. 服务篇

firewalld预定义了一些服务, 以便对不同服务授权不同的规则.

`--get-services`: 获取预定义的服务类型, 是`/usr/lib/firewalld/services`目录列出的种类. 大抵是`/usr/lib/firewalld/services`目标下的东西.