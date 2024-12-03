参考文章

1. [listing parent interface of a vlan](https://serverfault.com/questions/882754/listing-parent-interface-of-a-vlan)

## vlan id

查看当前系统中所有 vlan 设备的信息

```log
$ cat /proc/net/vlan/config
VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
VLAN.STG       | 302  | bond0
VLAN.K8S       | 303  | bond0
VLAN.MISC      | 4000  | bond0
VLAN.LB        | 304  | bond0
```

## 父设备

###

```log
$ cat /proc/net/vlan/vlan设备名称
VLAN.K8S  VID: 303       REORDER_HDR: 1  dev->priv_flags: 81021
         total frames received    339367435
          total bytes received 116387841558
      Broadcast/Multicast Rcvd         1580

      total frames transmitted    334379635
       total bytes transmitted 318444724557
Device: bond0
```

其中 Device 为其父设备, VID为其 vlan 号.

###

```json
// ip -json link show vlan设备名称
[{"ifindex":8,"link":"bond0","ifname":"vlan设备名称","flags":["BROADCAST","MULTICAST","UP","LOWER_UP"],"mtu":1500,"qdisc":"htb","operstate":"UP","linkmode":"DEFAULT","group":"default","txqlen":1000,"link_type":"ether","address":"","broadcast":"ff:ff:ff:ff:ff:ff"}]
```

其中`link`即为其父设备.

###

```log
$ ls /sys/class/net/VLAN.K8S/lower_* -al
lrwxrwxrwx 1 root root 0 Dec  3 13:51 /sys/class/net/VLAN.K8S/lower_bond0 -> ../bond0
```
