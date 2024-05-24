# veth设备设置mac地址

参考文章

1. [linux下使用ip命令修改mac地址](https://blog.csdn.net/legendmaker/article/details/10430475)

```log
$ ip link add veth01 addr ee:ee:ee:ee:ee:ee type veth peer name veth10 addr ee:ee:ee:ee:ee:ff
$ ip a
9: veth10@veth01: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether ee:ee:ee:ee:ee:ff brd ff:ff:ff:ff:ff:ff
10: veth01@veth10: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff
```
