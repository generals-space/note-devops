参考文章

关于路由, 准确的说, 系统中存在的与路由相关的术语有两种, 一种是**路由规则**, 一种是**路由表**. 

按照[Linux 路由和多网卡网关的路由出口设置](http://www.cnblogs.com/fengyc/p/6533112.html)中所说

> 路由规则指定当数据包满足规则时, 应转交到哪个路由表; 路由表根据数据包的信息, 选择下一跳.

所以通过route命令查看的叫做路由规则而不是真正的路由表, 使用`ip rule`查看的才是路由表.

------

路由是根据一定选择确定数据包流向的, 那这种选择与路由表条目中的顺序有关吗?

`ip link help`可以查看不同设备类型共有的选项参数, 但有很多选项是各类型独有的, 比如bridge类型的vlan过滤.

可以使用`ip link add type [ bridge | vlan | ...] help`

以`bridge`类型为例.

```log
[root@k8s-worker-7-17 ~]# ip link add type bridge help
Usage: ... bridge [ forward_delay FORWARD_DELAY ]
                  [ hello_time HELLO_TIME ]
                  [ max_age MAX_AGE ]
                  [ ageing_time AGEING_TIME ]
                  [ stp_state STP_STATE ]
                  [ priority PRIORITY ]
                  [ group_fwd_mask MASK ]
                  [ group_address ADDRESS ]
                  [ vlan_filtering VLAN_FILTERING ]
                  [ vlan_protocol VLAN_PROTOCOL ]
                  [ vlan_default_pvid VLAN_DEFAULT_PVID ]
... ## 省略
Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }
```

```
ip link set br0 vlan vlan_filtering 1
```

能显示更多可用选项, 但是貌似没办法查看, 至少暂时还没找到可用的命令.

另外, 由于ip命令集成了很多子命令, 但是在`man ip`中看到的只是比较笼统的信息, 各种子命令其实可以在`man ip`的`SEE ALSO`节找到各子命令的查阅方法, 如`man ip-link`, `man ip-address`等.

但是, `ip link`基本上只提供各种设备最基础的, 通用的设置, 更多具体的, 或是独有的操作需要用专门的工具完成.

比如对bridge的操作, `ip link`并不能提供管理vlan的操作(精确到端口), 以及对tag的管理.

------

## ip选项

`ip -s link|addr`: 可以显示更详细的内容(一般是各接口设备收发或是出错的数据包数量汇总信息)

`ip -d link`: 可以打印出vlan设备的id信息.
