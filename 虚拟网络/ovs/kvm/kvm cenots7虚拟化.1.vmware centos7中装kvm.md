# vmware centos7中装kvm

参考文章

1. [烂泥：虚拟化KVM安装与配置](https://www.cnblogs.com/ilanni/p/3863526.html)
    - `lsmod | grep kvm`其实在vmware开启cpu虚拟化的时候, 启动虚拟机就有了, 不是在安装完kvm包的时候才有的.
    - 命令有点旧, 不怎么适用
2. [KVM的NAT网络和bridge网络安装](https://blog.csdn.net/weixin_43445431/article/details/105453602)
3. [linux上kvm虚拟机网络不通的问题解决方法](https://blog.csdn.net/weixin_42915431/article/details/121682366)
4. [Virtual Networking for VirtualBox using Open vSwitch](https://ariscahyadi.wordpress.com/2013/07/16/virtual-networking-for-virtualbox-using-open-vswitch/)
    - virtualbox 设置虚拟机桥接至 openvswitch 网桥

```
yum -y install qemu-kvm libvirt python-virtinst bridge-utils virt-install virt-viewer virt-manager
```

下面我们检测下kvm是否安装成功，我们可以使用以下命令

```
virsh -c qemu:///system list
```

参考文章1中说初次安装, 需要重启一下服务器, 否则会报错, 我这里没看到, 直接就成功了.

```log
$ virsh -c qemu:///system list
 Id    Name                           State
----------------------------------------------------
```

创建虚拟机磁盘

```
$ qemu-img create -f qcow2 /mnt/hgfs/share/kvm01.disk 15G
Formatting '/mnt/hgfs/share/kvm01.disk', fmt=qcow2 size=16106127360 encryption=off cluster_size=65536 lazy_refcounts=off
```

> 虽然这里指定了15G, 但并不是立即分配15G.

```log
$ virt-install --virt-type kvm --name kvm01 --boot hd,cdrom,menu=on --memory 512,maxmemory=1024 --vcpus 1 --os-variant=rhel7 --cdrom /mnt/hgfs/share/CentOS-7-x86_64-Minimal-2009.iso --disk path=/mnt/hgfs/share/kvm01.disk,size=4,format=qcow2 --network network=default --graphics vnc,listen=0.0.0.0
WARNING  Graphics requested but DISPLAY is not set. Not running virt-viewer.
WARNING  No console to launch for the guest, defaulting to --wait -1

Starting install...
Allocating 'kvm01.disk'                                                                                                                                  | 4.0 GB  00:00:05
Domain installation still in progress. Waiting for installation to complete.
Domain has shutdown. Continuing.
Domain creation completed.
Restarting guest.
```

然后进入 vmware centos 图形界面, 在命令终端中执行`virt-manager`

![]()

双击, 开始正常的安装流程.

![]()

启动后, 进入kvm虚拟机命令行, 执行`ip a`命令, 发现没有ip, 网络不通.

![]()

我以为是我安装的过程存在问题, 按照参考文章3中查了下vmware centos主机的网络接口信息, 结果发现, nat的`vnet0`接口也没有ip...

virt-install --virt-type kvm --name kvm03 --boot hd,cdrom,menu=on --memory 512,maxmemory=1024 --vcpus 1 --os-variant=rhel7 --cdrom /mnt/hgfs/share/CentOS-7-x86_64-Minimal-2009.iso --disk path=/mnt/hgfs/share/kvm03.disk,size=4,format=qcow2 --network network=default --graphics vnc,listen=0.0.0.0
virt-install --virt-type kvm --name kvm04 --boot hd,cdrom,menu=on --memory 512,maxmemory=1024 --vcpus 1 --os-variant=rhel7 --cdrom /mnt/hgfs/share/CentOS-7-x86_64-Minimal-2009.iso --disk path=/mnt/hgfs/share/kvm04.disk,size=4,format=qcow2 --network network=default --graphics vnc,listen=0.0.0.0
