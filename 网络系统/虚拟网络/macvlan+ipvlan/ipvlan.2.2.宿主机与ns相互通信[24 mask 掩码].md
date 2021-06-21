# ipvlan.2.2.宿主机与ns相互通信[24 mask 掩码]

参考文章

1. [K8S CNI之：利⽤ ipvlan + host-local 打通容器与宿主机的平⾏⽹络](https://juejin.cn/post/6844903801057443853)
    - 借助`ptp`原理实现在macvlan/ipvlan模型下容器与宿主机网络互通.
2. [K8S CNI之：利用ipvlan+host-local+ptp打通容器与宿主机的平行网络](https://hansedong.github.io/2019/03/19/14/)
    - 参考文章1的原链接
3. [Linux网络协议栈6--ipvlan](https://www.jianshu.com/p/783fe769f335)
    - 场景有效, 但是示例中错误太多...太难了
4. [Kubernetes网络的IPVlan方案](https://kernel.taobao.org/2019/11/ipvlan-for-kubernete-net/)

前一篇文章已经通过修改`rp_filter`配置, 实现了ipvlan网络中的宿主机与ns互通的场景, 但是在做其他实验时, 我又发现了另外一种可能的实现, 本文重新进行论证.

## 环境准备

VMware Nat网络模式

- vm01: 172.16.91.10/24
- vm02: 172.16.91.14/24

网关与DNS地址都是`172.16.91.2`.

## L3

在vm02上执行如下命令, 创建两个ipvlan设备, 并分别放入2个ns中.

```bash
ip link add link ens34 ipvlan1 type ipvlan mode l3
ip link add link ens34 ipvlan2 type ipvlan mode l3

## 创建ns
ip net add ns01
ip net add ns02

## 将 ipvlan 设备分为移入指定ns
ip link set ipvlan1 netns ns01
ip link set ipvlan2 netns ns02

## 要先将 ipvlan 设备放入 ns, 然后设置IP, 否则移入后地址会被置空
ip net exec ns01 ip addr add 172.16.91.101/24 dev ipvlan1
ip net exec ns02 ip addr add 172.16.91.102/24 dev ipvlan2
ip net exec ns01 ip link set ipvlan1 up
ip net exec ns02 ip link set ipvlan2 up

## 设置默认路由
ip net exec ns01 ip route add default dev ipvlan1
ip net exec ns02 ip route add default dev ipvlan2
```

```bash
ip link add link ens34 ipvlan0 type ipvlan mode l3
ip addr add 192.168.1.1/24 dev ipvlan0
ip link set ipvlan0 up
ip r add 172.16.91.101 dev ipvlan0 
ip r add 172.16.91.102 dev ipvlan0 
```

主要变动有两个

1. ns中的默认路由不再使用父接口的`172.16.91.14`作为下一跳网关;
2. 中转接口`ipvlan0`的IP掩码设置为24;

网络连通表现如下

- [x] ns01 <-------> ns02
- [ ] ns01/ns02 <--> vm01(`172.16.91.10`)
- [ ] ns01/ns02 <--> Gateway(`172.16.91.2`)
- [x] ns01/ns02 <--> vm02.ipvlan0(`192.168.1.1`)
- [x] ns01/ns02 ---> vm02.ens34(`172.16.91.14`)

虽然能ping通宿主机了, 但是ping不通物理网络中的其他主机了, 有点舍本逐末...

## L2

重置网络, 将上面的命令中, ipvlan的模式调整为L2, 网络连通表现如下

- [x] ns01 <-------> ns02
- [x] ns01/ns02 <--> vm01(`172.16.91.10`)
- [x] ns01/ns02 <--> Gateway(`172.16.91.2`)
- [x] ns01/ns02 <--> vm02.ipvlan0(`192.168.1.1`)
- [ ] ns01/ns02 ---> vm02.ens34(`172.16.91.14`)

...与本机通信还是要修改`rp_filter`.

## 原因分析

...???
