# ip monitor监控命令

参考文章


```console
$ ip link add flannel0 type bridge
$ ip link del flannel0 type bridge
```

在执行上述命令前先再开一个控制台, 执行如下命令等待

```console
$ ip monitor all 
[NEIGH]172.16.91.2 dev ens33 lladdr 00:50:56:ee:ae:a4 REACHABLE
[NEIGH]lladdr 12:51:24:0d:11:b0 PERMANENT
[LINK]5: flannel0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default
    link/ether 12:51:24:0d:11:b0 brd ff:ff:ff:ff:ff:ff
[NEIGH]172.16.91.2 dev ens33 lladdr 00:50:56:ee:ae:a4 STALE
[NEIGH]Deleted dev flannel0 lladdr 12:51:24:0d:11:b0 PERMANENT
[LINK]Deleted 5: flannel0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default
    link/ether 12:51:24:0d:11:b0 brd ff:ff:ff:ff:ff:ff
```
