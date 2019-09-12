# ip与brctl-管理bridge设备的命令对照

参考文章

1. [网络虚拟化技术（一）: Linux网络虚拟化](https://blog.kghost.info/2013/03/01/linux-network-emulator/)

2. [Network bridge](https://wiki.archlinux.org/index.php/Network_bridge)

要允许系统对bridge设备的管理, 需要启动相关模块 `modprobe br_netfilter`

| 操作类型                        | brctl                 | ip                                  |
| :------------------------------ | :-------------------- | :---------------------------------- |
| 创建bridge设备 br0              | brctl addbr br0       | ip link add br0 type bridge         |
| 启动bridge设备 br0              | <无>                  | ip link set dev br0 up              |
| 删除设备 br0                    | brctl delbr br0       | ip link del dev br0                 |
| 将veth设备端 veth0 连接到 br0   | brctl addif br0 veth0 | ip link set dev veth0 master br0    |
| 移除veth设备端在 br0上的连接    | brctl delif br0 veth0 | ip link set dev veth0 nomaster      |
| 查看本机上的bridge设备列表      | brctl show            | ip link show type bridge            |
| 查看bridge设备 br0 上连接的接口 | brctl show br0        | ip link show master br0 type bridge |

在使用`brctl delbr`删除一个bridge设备前, 需要使用`ip`命令将该设备设置为down的状态, 否则会出错.

```
bridge br0 is still up; can't delete it
```
