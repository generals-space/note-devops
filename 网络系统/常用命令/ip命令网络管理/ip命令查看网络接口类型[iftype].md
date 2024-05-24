# ip命令查看网络接口类型

参考文章

1. [How to determine the logical type of a linux network device](https://unix.stackexchange.com/questions/272850/how-to-determine-the-logical-type-of-a-linux-network-device)

通过`ip link add xxx type 类型名称`创建的网络接口, 好像没有明显的命令可以查看.

```
TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |
          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |
          gre | gretap | ip6gre | ip6gretap | vti | nlmon |
          bond_slave | geneve | bridge_slave | macsec }
```

按照参考文章1的回答所说, 只能通过`ip link show type 类型名称`查看对应的接口列表, 并没有能够直接查看某一接口的类型的...

```bash
#!/bin/bash

# Arguments: $1: Interface ('grep'-regexp).

# Static list of types (from `ip link help`):
TYPES=(bond bond_slave bridge dummy gre gretap ifb ip6gre ip6gretap ip6tnl ipip ipoib ipvlan macvlan macvtap nlmon sit vcan veth vlan vti vxlan tun tap)

iface="$1"

for type in "${TYPES[@]}"; do
    ip link show type "${type}" | grep -E '^[0-9]+:' | cut -d ':' -f 2 | sed 's|^[[:space:]]*||' | while read _if; do
        echo "${_if}:${type}"
    done | grep "^${iface}"
done
```

```log
[root@k8s-worker-7-17 ~]# ./iftype.sh docker0
docker0:bridge
[root@k8s-worker-7-17 ~]# ip link show type bridge
6: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT
    link/ether 02:42:60:96:51:90 brd ff:ff:ff:ff:ff:ff
[root@k8s-worker-7-17 ~]# ./iftype.sh bond1
bond1:bond
```

行吧, 勉强能用.
