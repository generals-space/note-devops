参考文章

1. [openvswitch安装部署+ovs网桥配置](https://blog.csdn.net/qq_44735930/article/details/108854920)
    - yum安装openvswitch
    - centos7官方仓库中没有openvswitch包, 需要额外执行`yum install -y centos-release-openstack-queens`, 下载repo包.
2. [CentOS7安装Openvswitch 2.3.0 LTS](https://cloud.tencent.com/developer/article/2038924)
    - 源码安装
3. [Centos7安装最新版openvswitch](https://www.cnblogs.com/bingbing721/p/13751579.html)
    - 源码安装
4. [Installing Open vSwitch](https://docs.openvswitch.org/en/latest/intro/install/)
    - 官方文档

```
yum install -y centos-release-openstack-queens
yum install -y openvswitch.x86_64
```


systemctl start openvswitch
systemctl enable openvswitch

```console
$ ovs-vsctl add-br ovs-br0
$ ip -d addr
6: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether c6:1b:96:be:26:7c brd ff:ff:ff:ff:ff:ff promiscuity 1
    openvswitch numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
7: ovs-br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 36:96:84:36:26:4a brd ff:ff:ff:ff:ff:ff promiscuity 1
    openvswitch numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
```



iptables -t filter -A FORWARD -t ACCEPT
