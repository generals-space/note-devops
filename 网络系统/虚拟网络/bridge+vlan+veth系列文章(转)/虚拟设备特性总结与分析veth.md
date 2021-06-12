# 虚拟设备特性总结与分析veth

## 关于`link-netnsid`

初始veth pair状态如下.

```console
[root@k8s-worker-7-17 ~]# ip link add type veth
[root@k8s-worker-7-17 ~]# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: veth0@veth1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether ba:6c:51:73:44:9f brd ff:ff:ff:ff:ff:ff
3: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 56:f6:13:ec:f3:78 brd ff:ff:ff:ff:ff:ff
```

当veth pair被分别放到两个不同的`netns`后, 就会出现`link-netnsid`字段, 而这个字段与**对端**的`netns`相关.

假设当前所在的netns为`test`, 我们将veth1设备放到另一个`netns1`中. 

```console
[root@k8s-worker-7-17 ~]# ip netns ls
test
netns1
## 这要求目标netns中没有同名的设备, 否则会报错. `RTNETLINK answers: Invalid argument`
[root@k8s-worker-7-17 ~]# ip link set veth1 netns netns1
[root@k8s-worker-7-17 ~]# ip netns ls
test
netns1
```

此时再查看原来的命名空间的设备列表.

```console
[root@k8s-worker-7-17 ~]# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: veth0@if11: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether ba:6c:51:73:44:9f brd ff:ff:ff:ff:ff:ff link-netnsid 0
[root@k8s-worker-7-17 ~]# ip netns ls
test
netns1 (id: 0)
```

`link-netnsid 0`正好对应着`netns1 (id: 0)`, 在`netns1`空间中可以看到相似的输出.

注意这里的0是相对值, 对端`netns1`中看到的也是相对值, 不同netns下看到其他netns的id是不同的.
