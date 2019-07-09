# Linux查看系统与硬件信息(三)hostnamectl

`hostnamectl`是CentOS7中的命令, 可以查看hostname值, 系统类型, 内核版本等信息. 它是systemd机制中`systemd-hostnamed.service`服务的客户端操作工具.

```
$ hostnamectl status
   Static hostname: localhost.localdomain
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 7bc63b73c29c49a8b16c98b90102dd38
           Boot ID: fb1752d30adc4260a71f2799d2b9ce92
    Virtualization: vmware
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-327.28.3.el7.x86_64
      Architecture: x86-64
```
