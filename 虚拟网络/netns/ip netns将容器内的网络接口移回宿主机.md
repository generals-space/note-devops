## 将一个网络接口放到某个命名空间后, 如何将其移出来?

~~首先, 将目标netns删掉, 是可以将其移出来的~~ 错了, 如果直接删掉netns, 则这个网络设备也消失了.

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
# ip netns del ns01
# ip link show | grep -E 'veth01|veth02'
## 直接消失了
```

> 尝试将放到 ns01 的 veth 一端, 或是另一端, 接入宿主机空间的某个 bridge, 仍然无效, 还是 veth 设备两端都会随着 netns 删除而删除.

> 不过某些物理网卡在netns删除后, 是可以逃出来的, 目前还不清楚具体规则.

## 正确做法

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

## 以下是正确的做法
# ip netns exec ns01 ip link set veth02 netns 1
# ip link show | grep -E 'veth01|veth02'
82: veth02@veth01: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
83: veth01@veth02: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
```

> `netns 1`表示根命名空间(PID=1, 的进程所属的命名空间)

