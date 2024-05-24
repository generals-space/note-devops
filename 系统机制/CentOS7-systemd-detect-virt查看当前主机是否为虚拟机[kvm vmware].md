# CentOS查看当前主机是否为虚拟机[kvm vmware]

参考文章

1. [阿里云ECS的centos环境](https://www.cnblogs.com/architectforest/p/12573877.html)

系统版本: centos7

```log
$ systemd-detect-virt
kvm
```

`systemd-detect-virt`可能输出`kvm`, `vmware`等.
