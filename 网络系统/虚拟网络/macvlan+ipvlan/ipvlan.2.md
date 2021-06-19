参考文章

1. [K8S CNI之：利⽤ ipvlan + host-local 打通容器与宿主机的平⾏⽹络](https://juejin.cn/post/6844903801057443853)
    - 借助`ptp`原理实现在macvlan/ipvlan模型下容器与宿主机网络互通.
2. [K8S CNI之：利用ipvlan+host-local+ptp打通容器与宿主机的平行网络](https://hansedong.github.io/2019/03/19/14/)

```bash
ip link add link ens34 ipvlan1 type ipvlan mode l2

## 创建ns
ip net add net01

## 将 ipvlan 设备分为移入指定ns
ip link set ipvlan1 netns net01

## 要先将 ipvlan 设备放入 ns, 然后设置IP, 否则移入后地址会被置空
ip net exec net01 ip addr add 172.16.92.101/24 dev ipvlan1
ip net exec net01 ip link set ipvlan1 up
ip net exec net01 ip r add default via 172.16.91.14 dev ipvlan1



ip link add link ens34 ipvlan2 type ipvlan mode l2
ip addr add 172.16.93.101/32 dev ipvlan2
ip link set ipvlan2 up
ip r add 172.16.92.101 dev ipvlan2 scope link

ip neigh 172.16.92.101 dev ipvlan2 lladdr 00:0c:29:51:4c:e0
```



ip link add link ens34 ipvlan1 type ipvlan mode l2
ip link add link ens34 ipvlan2 type ipvlan mode l2

## 创建ns
ip net add net01
ip net add net02

## 将 ipvlan 设备分为移入指定ns
ip link set ipvlan1 netns net01
ip link set ipvlan2 netns net02

## 要先将 ipvlan 设备放入 ns, 然后设置IP, 否则移入后地址会被置空
ip net exec net01 ip addr add 192.168.2.18/24 dev ipvlan1
ip net exec net02 ip addr add 192.168.2.19/24 dev ipvlan2
ip net exec net01 ip link set ipvlan1 up
ip net exec net02 ip link set ipvlan2 up

## 设置默认路由
ip net exec net01 ip route add default via 192.168.2.19 dev ipvlan1
ip net exec net02 ip route add default via 192.168.2.18 dev ipvlan2

ip link add link ens34 ipvlan3 type ipvlan mode l2
ip addr add 10.0.3.1/32 dev ipvlan3
ip link set ipvlan3 up

ip r add 192.168.2.18 dev ipvlan3 
ip r add 192.168.2.19 dev ipvlan3 
ip neigh add 192.168.2.18 dev ipvlan3 lladdr 00:0c:29:51:4c:e0

















```bash
ip link add link ens34 ipvlan1 type ipvlan mode l2
ip link add link ens34 ipvlan2 type ipvlan mode l2

## 创建ns
ip net add net01
ip net add net02

## 将 ipvlan 设备分为移入指定ns
ip link set ipvlan1 netns net01
ip link set ipvlan2 netns net02

## 要先将 ipvlan 设备放入 ns, 然后设置IP, 否则移入后地址会被置空
ip net exec net01 ip addr add 192.168.2.11/24 dev ipvlan1
ip net exec net02 ip addr add 192.168.2.12/24 dev ipvlan2
ip net exec net01 ip link set ipvlan1 up
ip net exec net02 ip link set ipvlan2 up

## 设置默认路由
ip net exec net01 ip route add default dev ipvlan1
ip net exec net02 ip route add default dev ipvlan2
```

```
ip link add link ens34 ipvlan3 type ipvlan mode l2
ip addr add 192.168.2.13/24 dev ipvlan3
ip link set ipvlan3 up
```
