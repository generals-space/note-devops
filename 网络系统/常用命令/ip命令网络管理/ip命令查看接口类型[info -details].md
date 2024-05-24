# ip命令查看接口类型[info -details]

参考文章

1. [How can i get the name of the interface, its type and ip?](https://unix.stackexchange.com/questions/643926/how-can-i-get-the-name-of-the-interface-its-type-and-ip)

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

