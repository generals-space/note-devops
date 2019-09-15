# bridge命令管理vlan(二)-untagged

```
ip netns add netns1
ip netns add netns2
ip link add veth1 type veth peer name veth2
ip link set veth1 netns netns1
ip link set veth2 netns netns2
ip netns exec netns2 ip link add veth21 type veth peer name veth22
ip netns exec netns2 ip link add mybr2 type bridge
## 启动
ip netns exec netns1 ip link set veth1 up
ip netns exec netns2 ip link set veth2 up
ip netns exec netns2 ip link set veth21 up
ip netns exec netns2 ip link set veth22 up
ip netns exec netns2 ip link set mybr2 up
ip netns exec netns1 ip addr add 10.1.1.1/24 dev veth1
ip netns exec netns2 ip addr add 10.1.1.2/24 dev veth22
## netns2中配置bridge与vlan
ip netns exec netns2 ip link set veth2 master mybr2
ip netns exec netns2 ip link set veth21 master mybr2
ip netns exec netns2 ip link set dev mybr2 type bridge vlan_filtering 1
```

最初的vlan配置如下

```
[root@k8s-worker-7-17 ~]# bridge vlan show
port	vlan ids
veth2	 1 PVID Egress Untagged
veth21	 1 PVID Egress Untagged
mybr2	 1 PVID Egress Untagged
```

从netns1中`ping 10.1.1.2`, 在netns2中抓包如下

```
[root@k8s-worker-7-17 ~]# tcpdump -vvv -n -i veth21 -e
tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
16:39:13.991751 6e:c1:18:37:93:79 > d2:0a:94:45:85:bf, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 47386, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 3195, seq 1, length 64
16:39:13.991810 d2:0a:94:45:85:bf > 6e:c1:18:37:93:79, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 59851, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 3195, seq 1, length 64
16:39:14.992070 6e:c1:18:37:93:79 > d2:0a:94:45:85:bf, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 47387, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 3195, seq 2, length 64
16:39:14.992124 d2:0a:94:45:85:bf > 6e:c1:18:37:93:79, ethertype IPv4 (0x0800), length 98: (tos 0x0, ttl 64, id 60810, offset 0, flags [none], proto ICMP (1), length 84)
    10.1.1.2 > 10.1.1.1: ICMP echo reply, id 3195, seq 2, length 64
```

没什么特殊情况, 貌似是把vlan id为1忽略掉了.

```
## 重建vlan条目, 先删除
ip netns exec netns2 bridge vlan del dev veth2 vid 1
ip netns exec netns2 bridge vlan del dev veth21 vid 1
## 注意删除bridge本身的条目时要加`self`标记, 否则会出错
## ip netns exec netns2 bridge vlan del dev mybr2 vid 1
## RTNETLINK answers: Operation not supported
ip netns exec netns2 bridge vlan del dev mybr2 vid 1 self
## 再新建
ip netns exec netns2 bridge vlan add dev veth2 vid 1 pvid
ip netns exec netns2 bridge vlan add dev veth21 vid 1 pvid
```

```
[root@k8s-worker-7-17 ~]# bridge vlan show
port	vlan ids
veth2	 1 PVID
veth21	 1 PVID
mybr2	None
```

再ping(此时已经ping不通了...), 再抓包.

```
## veth21
ip netns exec netns2 tcpdump -vvv -n -i veth21 -e

tcpdump: listening on veth21, link-type EN10MB (Ethernet), capture size 262144 bytes
16:45:43.119577 6e:c1:18:37:93:79 > d2:0a:94:45:85:bf, ethertype 802.1Q (0x8100), length 102: vlan 1, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 51916, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 3882, seq 1, length 64
16:45:44.119056 6e:c1:18:37:93:79 > d2:0a:94:45:85:bf, ethertype 802.1Q (0x8100), length 102: vlan 1, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 52612, offset 0, flags [DF], proto ICMP (1), length 84)
    10.1.1.1 > 10.1.1.2: ICMP echo request, id 3882, seq 2, length 64

## veth22
ip netns exec netns2 ip netns exec netns2 tcpdump -vvv -n -i veth22 -e

tcpdump: listening on veth22, link-type EN10MB (Ethernet), capture size 262144 bytes
20:55:49.781741 0e:8d:57:8a:22:58 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 1, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
20:55:50.783975 0e:8d:57:8a:22:58 > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 1, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28

```

发现从bridge出来后, 在mybr2 -> veth21的包有vlan的标记, 正好是1. 而且在veth21应该就被丢弃了, 因为包没有到veth22.

我们知道在veth2接入bridge的tag为1的接口, 那么bridge就会将veth2的请求转发给其他tag也为1的接口. 默认情况下, 包转发出来的时候bridge会将tag 1移除, 以免影响其最终目的地.

现在没有移除vlan tag, 而`veth21`和`veth22`没有能够接收vlan tag为1的包的能力, 所以无法回应.

那么, 怎么解决呢? 做如下挣扎...

扔掉veth21和veth22, 在veth21上创建vlan子接口看看能不能通吧.

```
ip netns exec netns2 ip link add link veth21 name veth21.1 type vlan id 1
ip netns exec netns2 ip link add link veth22 name veth22.1 type vlan id 1
ip netns exec netns2 ip link set veth21.1 up
ip netns exec netns2 ip link set veth22.1 up
ip netns exec netns2 ip addr del 10.1.1.2/24 dev veth22
ip netns exec netns2 ip link set veth21 nomaster
ip netns exec netns2 ip link set veth21.1 master mybr2
ip netns exec netns2 ip addr add 10.1.1.2/24 dev veth22.1
```

...netns1再次ping失败, 但是包能走到`veth22.1`, 而且我想并没有被丢弃, 只是没法按照原路返回.

```
[root@k8s-worker-7-17 ~]# tcpdump -vvv -n -i veth22.1 -e
tcpdump: listening on veth22.1, link-type EN10MB (Ethernet), capture size 262144 bytes
21:26:58.250184 0e:8d:57:8a:22:58 > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
21:26:58.250231 32:95:61:9d:ed:53 > 0e:8d:57:8a:22:58, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Reply 10.1.1.2 is-at 32:95:61:9d:ed:53, length 28
21:26:59.251950 0e:8d:57:8a:22:58 > Broadcast, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 10.1.1.2 tell 10.1.1.1, length 28
21:26:59.251986 32:95:61:9d:ed:53 > 0e:8d:57:8a:22:58, ethertype ARP (0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Reply 10.1.1.2 is-at 32:95:61:9d:ed:53, length 28
```

因为虽然在netns2这一端可以接受vlan id为1的包, 但是原路返回时, 从mybr2 -> veth2, 由于veth2也没有处理带vlan id的包的能力, 所以就跪了.

当然也可以尝试在veth2上再加一对veth pair, 然后分别创建vlan子接口, 但是太麻烦了, 这里就不实验了.
