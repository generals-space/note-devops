# vxlan参数解析[learning bgp]

```
ip link add vxlan0 type vxlan id 1 dstport 0 dev ens33 bgp [no]learning
```

`id`必须存在, 且不可为1.
dstport: 必须存在, 可以为0. 如果不为0, 设备在启动时会自动监听一个UDP端口; 如果为0, 则发送的是OTV广播包???
proxy: 开启 ARP 压缩
learning: 学习远端主机的 MAC 地址，也就是 VXLAN 的 flood and learn
ageing: 学习到本地 fdb 的主机 MAC地址 的超时时间
maxaddress: fdb 表项的最大数目
