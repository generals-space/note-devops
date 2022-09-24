# apt update出现 The repository is not signed - The following signatures couldn't be verified because the public key is not available[NO_PUBKEY]

参考文章

1. [cri-o/cri-o](https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems)
2. [Linux 异常：The following signatures couldn‘t be verified because the public key is not available](https://blog.csdn.net/TineAine/article/details/118455874)

ubuntu: 20.04

## 问题描述

在部署 kubernetes 1.25.1 时, 不再支持 docker, 于是额外安装 cri-o 运行时工具.

但在按照参考文章1中部署操作, 出现如下问题

```console
$ echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/backports.list
$ apt update
Get:1 https://mirrors.aliyun.com/docker-ce/linux/ubuntu focal InRelease [57.7 kB]
...
Err:3 http://deb.debian.org/debian buster-backports InRelease
  The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 648ACFD622F3D138 NO_PUBKEY 0E98404D386FA1D9
...
Hit:9 http://us.archive.ubuntu.com/ubuntu focal-backports InRelease
Reading package lists... Done
W: GPG error: http://deb.debian.org/debian buster-backports InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 648ACFD622F3D138 NO_PUBKEY 0E98404D386FA1D9
E: The repository 'http://deb.debian.org/debian buster-backports InRelease' is not signed.
```

## 解决方法

这个问题有点像 yum 安装时的 gpgkey check 问题.

按照参考文章2中所说, 手动导入该 PUBKEY 就可以了, 上面缺失了2个key, 这里要导入两次.

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
```

`keyserver.ubuntu.com`不知道是干啥的...
