netns允许嵌套.

将

```bash
# ip link show | grep -E 'veth01|veth02'
# ip netns add ns01
# ip link add veth01 type veth peer name veth02
# ip link show | grep -E 'veth01|veth02'
82: veth02@veth01: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
83: veth01@veth02: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
# ip link set veth02 netns ns01
# ip link show | grep -E 'veth01|veth02'
83: veth01@if82: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
```

```bash
# ip netns exec ns01 bash
# ip netns add ns11
# ip netns ls
ns11 (id: 1)
ns01          ## 这里 ns01 可以看到自己...
# ip link set veth02 netns ns11
# ip link show | grep -E 'veth01|veth02'
## 此处为空
```

此时 veth01/veth02 与 netns 级联关系如下

```
1                   veth01
├─ns01
    ├─ns11          veth02
```

进到ns11空间, 将 veth02 移动到`netns 1`, 是会将其移到上一层的 ns01, 还是宿主机网络空间呢?

```
# ip netns exec ns11 bash
# ip netns ls
ns11
ns01
# ip link show | grep -E 'veth01|veth02'
92: veth02@if93: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
ip link set veth02 netns 1
```

答案是后者, 会直接回到宿主机空间. 

看来 netns 1 是一个id, 而非别名的存在.
