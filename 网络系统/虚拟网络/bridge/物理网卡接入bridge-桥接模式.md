## 物理网卡接入bridge-桥接模式

`ip link set eth0 master mybr0`把物理网卡连接到`bridge`设备也是可以的, 这相当于把`eth0`当作一根网线, 而`bridge`取代ta作为网卡运行. 

其实这也是vmware/virtualbox虚拟机上的桥接模式的实现原理, 网络拓扑基本相同.

示例如下

vmware环境下, 测试机`eth0`: `172.16.91.128/24`, DNS和网关地址都是`172.16.91.2`.

使用如下命令创建`mybr0`设备

```bash
ip link add mybr0 type bridge
ip link set mybr0 up
ip link set eth0 master mybr0
```

这样就断网了...

补救的方法是, 把`eth0`从`mybr0`中移除. 

## 1. 实验1

但是也有其他的解决方法. 

进入虚拟机终端, 执行如下命令.

```bash
ip addr add 172.16.91.211/24 dev mybr0
```

这样会在`mybr0`接口上添加地址, 这样就可以通过`mybr0`上的地址访问目标服务器了.

**注意**

1. IP地址`172.16.91.211`只要是该子网中任一可用的IP即可.
2. `mybr0`设备必须启动(只启动不添加地址也是不行的).

另外, 由于系统中原来的默认路由走的是`eth0`, `default via 172.16.91.2 dev eth0`(`via`中的是此网段的网关地址), 我们需要把默认路由从`eth0`改为`mybr0`, 否则无法ping通外网.

```
ip route add default via 172.16.91.2 dev mybr0
ip route del default via 172.16.91.2 dev eth0
```

这样, 就可以使用`mybr0`接口上的地址`172.16.91.211`重新建立通信了. 原来的`eth0`设备上虽然还存在IP且该地址仍能被子网中其他主机访问到, 但其实是可以删掉的. `eth0`还是乖乖当网线比较好.

## 2. 实验2

但是通过另外的IP访问毕竟不方便, 如果是线上主机, 保持服务器地址固定很重要.

其实我们也可以直接把`eth0`上的地址分配到`mybr0`上.

进入到虚拟机终端, 执行如下命令.

```bash
ip addr del 172.16.91.128/24 dev eth0
ip addr add 0.0.0.0 dev eth0
ip addr add 172.16.91.128/24 dev mybr0
```

然后再看一下路由是否有变动, 我这里实验的时候默认路由不见了, 所以需要手动创建一条.

```bash
ip route add default via 172.16.91.2 dev mybr0
```

然后就一切恢复正常了.
