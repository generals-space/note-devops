# bridge vs brctl

参考文章

1. [Comparison of BRCTL and BRIDGE commands](https://sgros-students.blogspot.com/2013/11/comparison-of-brctl-and-bridge-commands.html)
    - 分别介绍了`brctl`与`bridge`对虚拟网桥设备的操作, 对`FDB`(转发DB `Forwarding Database`)及`STP`(生成树协议 `Spanning Tree Protocol`)的概念有简单介绍.
    - 以表格形式展示两者的交叉与互补

`bridge`属于`iproute2`软件包, 而`brctl`属于`bridge-utils`软件包. 

## BRIDGE MANAGEMENT

| ACTION                            | brctl                           | bridge | remark                 |
| :-------------------------------- | :------------------------------ | :----- | :--------------------- |
| creating bridge                   | `brctl addbr <bridge>`          |        | 创建网桥               |
| deleting bridge                   | `brctl delbr <bridge>`          |        | 删除网桥               |
| add interface (port) to bridge    | `brctl addif <bridge> <ifname>` |        | 向网桥中添加接口       |
| delete interface (port) on bridge | `brctl delbr <bridge>`          |        | 从网桥中移除接口       |
| delete interface (port) on bridge | `brctl show <bridge>`           |        | 查看网桥中已连接的接口 |

## FDB MANAGEMENT

| ACTION                              | brctl                                 | bridge                                                 |
| :---------------------------------- | :------------------------------------ | :----------------------------------------------------- |
| Shows a list of MACs in FDB         | `brctl showmacs <bridge>`             | `bridge fdb show [dev 设备名]`                         |
| Sets FDB entries ageing time        | `brctl setageingtime <bridge> <time>` |                                                        |
| Sets FDB garbage collector interval | `brctl setgcint <brname> <time>`      |                                                        |
| Adds FDB entry                      |                                       | `bridge fdb add dev <interface> [dst, vni, port, via]` |
| Appends FDB entry                   |                                       | `bridge fdb append (parameters same as for fdb add)`   |
| Deletes FDB entry                   |                                       | `bridge fdb delete (parameters same as for fdb add)`   |

## STP MANAGEMENT

| ACTION                                                       | brctl                                          | bridge                                           |
| :----------------------------------------------------------- | :--------------------------------------------- | :----------------------------------------------- |
| Turning STP on/off                                           | `brctl stp <bridge> <state>`                   |                                                  |
| Setting bridge priority                                      | `brctl setbridgeprio <bridge> <priority>`      |                                                  |
| Setting bridge forward delay                                 | `brctl setfd <bridge> <time>`                  |                                                  |
| Setting bridge 'hello' time                                  | `brctl sethello <bridge> <time>`               |                                                  |
| Setting bridge maximum message age                           | `brctl setmaxage <bridge> <time>`              |                                                  |
| Setting cost of the port on bridge                           | `brctl setpathcost <bridge> <port> <cost>`     | `bridge link set dev <port> cost <cost>`         |
| Setting bridge port priority                                 | `brctl setportprio <bridge> <port> <priority>` | `bridge link set dev <port> priority <priority>` |
| Should port proccess STP BDPUs                               |                                                | `bridge link set dev <port > guard [on, off]`    |
| Should bridge might send traffic on the port it was received |                                                | `bridge link set dev <port> hairpin [on,off]`    |
| Enabling/disabling fastleave options on port                 |                                                | `bridge link set dev <port> fastleave [on,off]`  |
| Setting STP port state                                       |                                                | `bridge link set dev <port> state <state>`       |

## VLAN MANAGEMENT

| ACTION                         | brctl | bridge                                                           |
| :----------------------------- | :---- | :--------------------------------------------------------------- |
| Creating new VLAN filter entry |       | `bridge vlan add dev <dev> [vid, pvid, untagged, self, master]`  |
| Delete VLAN filter entry       |       | `bridge vlan delete dev <dev> (parameters same as for vlan add)` |
| List VLAN configuration        |       | `bridge vlan show`                                               |
