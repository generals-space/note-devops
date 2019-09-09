# ip netns网络命名空间

参考文章

1. [[svc]通过bridge连接单机的多个网络namespace](https://www.cnblogs.com/iiiiher/p/8057922.html)
    - netns 基本操作
    - veth 设备连接两个 netns
    - bridge 设备连接多个 netns


`netns`相关的操作比较简单, 没什么特别难以理解的地方.

需要知道是, 每通过`ip netns add xxx`创建的ns会出现在`/var/run/netns`目录下.

```console
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

