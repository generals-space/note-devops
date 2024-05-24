# ip netns网络命名空间

参考文章

1. [[svc]通过bridge连接单机的多个网络namespace](https://www.cnblogs.com/iiiiher/p/8057922.html)
    - netns 基本操作
    - veth 设备连接两个 netns
2. [linux 网络虚拟化： network namespace 简介](https://cizixs.com/2017/02/10/network-virtualization-network-namespace/)
    - 应该是参考文章1的来源, 参考文章1对此添加了一些图片.


`netns`相关的操作比较简单, 没什么特别难以理解的地方.

需要知道是, 每通过`ip netns add xxx`创建的ns会出现在`/var/run/netns`目录下.

```log
[root@k8s-worker-7-17 ~]# ip netns add red
[root@k8s-worker-7-17 ~]# ip netns add green
[root@k8s-worker-7-17 ~]# cd /var/run/netns/
[root@k8s-worker-7-17 netns]# ll
总用量 0
-r--r--r-- 1 root root 0 9月   9 22:37 green
-r--r--r-- 1 root root 0 9月   9 22:37 red
[root@k8s-worker-7-17 netns]# cat green
cat: green: 无效的参数
```

...虽然看起来像常规文件, 但实际上不能使用`cat`查看内容.

进入网络空间

```
ip netns exec red bash
exit
```

初始的`netns`中只有一个lo网卡, 且是down状态.

假设在宿主机上曾经创建过veth设备对, 并将其中一个放到了某个netns中, 如red. 在使用`ip netns delete red`时会直接删除red网络空间, 其中的veth设备也会被删除, 只留一个veth设备在宿主机. 删除时不会报错, 也不会将veth重新放回到宿主机的netns.

## 同主机bridge连接不同netns实验

bridge 可以不设置ip, 只要把位于主机端的 veth 设备连接到 br0 上, 然后启用就可以.

连接命令

```
ip link set dev veth0 master br0
```

可以看作是将 veth0 网络的主机端连接到交换机 br0 上.
