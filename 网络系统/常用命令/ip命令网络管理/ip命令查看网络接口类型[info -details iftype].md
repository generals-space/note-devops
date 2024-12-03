# ip命令查看接口类型[info -details]

参考文章

1. [How can i get the name of the interface, its type and ip?](https://unix.stackexchange.com/questions/643926/how-can-i-get-the-name-of-the-interface-its-type-and-ip)
2. [How to determine the logical type of a linux network device](https://unix.stackexchange.com/questions/272850/how-to-determine-the-logical-type-of-a-linux-network-device)
   - 只能通过`ip link show type 类型名称`查看对应的接口列表, 并没有能够直接查看某一接口的类型的...

## ip -d

```log
$ ip -details address
## ip -d address
1225: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:0c:29:f6:d2:b7 brd ff:ff:ff:ff:ff:ff promiscuity 0
    bond mode active-backup active_slave ens34 miimon 100 updelay 0 downdelay 0 use_carrier 1 arp_interval 0 arp_validate none arp_all_targets any primary_reselect always fail_over_mac none xmit_hash_policy layer2 resend_igmp 1 num_grat_arp 1 all_slaves_active 0 min_links 0 lp_interval 1 packets_per_slave 1 lacp_rate slow ad_select stable tlb_dynamic_lb 1 numtxqueues 16 numrxqueues 16 gso_max_size 65536 gso_max_segs 65535
    inet 192.168.30.4/24 brd 192.168.30.255 scope global noprefixroute bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fef6:d2b7/64 scope link
       valid_lft forever preferred_lft forever
```

可以看到, `bond0`是`bond`类型, 模式为`active-backup`.

## 自定义 iftype 脚本

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

