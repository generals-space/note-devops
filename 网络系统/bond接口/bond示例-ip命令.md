# bond示例-ip命令

```console
ip link add bond0 type bond
## mode指定数值或是预设字符串应该都是可以的.
## ip link set bond0 type bond miimon 100 mode 1
ip link set bond0 type bond miimon 100 mode active-backup
## 目标网卡要先停止才能绑定, 否则会报`Operation not permitted`
ip link set eth0 down
ip link set eth0 master bond0
ip link set eth1 down
ip link set eth1 master bond0
## 启动bond设备的时候eth0与eth1也会随之启动
ip link set bond0 up
```
