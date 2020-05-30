# nmcli命令应用

参考文章

1. [解决Centos网卡IP和配置文件不符的问题]（http://icestrawberryxjw.me/2019/03/06/ip-conf-file-inconsistency/)
    - device: 物理接口; connection: 逻辑接口.
2. [在 RHEL8 配置静态 IP 地址的不同方法](https://juejin.im/post/5d8cde1151882509662c5b9b)
    - 配置静态IP, 保存并重新加载网络配置文件.
3. [CentOS 7 下网络管理之命令行工具nmcli](https://www.jianshu.com/p/5d5560e9e26a)
    - connection对象可设置的属性列表: `nmcli c show 连接名称`

md刚刚差不多学会ip命令, CentOS 8又把network服务移除了.

重命名 connection 对象

```console
$ nmcli c
NAME                    UUID                                                TYPE      DEVICE
Wired Connection 1      9115e4b3-75a0-3512-98b6-f82e6b15bb5d                ethernet  ens34
virbr0                  faf25db2-318a-46eb-8943-6082ffb7358a                bridge    virbr0
$ nmcli c mod Wired\ Connection\ 1 connection.id ens34
$ # 或者用 uuid 代替连接名称也可以
$ # nmcli c mod 9115e4b3-75a0-3512-98b6-f82e6b15bb5d connection.id ens34
$ nmcli c
NAME    UUID                                  TYPE      DEVICE
ens34   9115e4b3-75a0-3512-98b6-f82e6b15bb5d  ethernet  ens34
virbr0  faf25db2-318a-46eb-8943-6082ffb7358a  bridge    virbr0
```

> 貌似这样重命名一下就会生成`/etc/sysconfig/network-scripts/ifcfg-ens34`文件

删除指定connection对象

nmcli c delete 连接名称
nmcli c delete uuid 连接UUID

重新加载配置, 类似于`systemctl restart network`

nmcli c load /etc/sysconfig/network-scripts/ifcfg-eth0 (重启指定接口)
nmcli c reload (重启所有接口)

设置静态IP并导出网络配置(如果已经存在, 则在执行如下命令时会实时修改该文件)

```
nmcli con mod ens33 ipv4.addresses 192.168.0.201/24
nmcli con mod ens33 ipv4.gateway 192.168.0.1
nmcli con mod ens33 ipv4.dns 192.168.0.1
nmcli con mod ens33 ipv4.method static
nmcli con up ens33 ## 保存并重新加载
```
