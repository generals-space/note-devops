# Ubuntu 安装 docker

## 1. 14.04

下面这一段先不要尝试, 虽然方法很标准, 但安装完成后`docker pull`会出错.

------

参考文章

[在Ubuntu 14.04安装和使用Docker](http://blog.csdn.net/chszs/article/details/47122005)

### 1.1 环境要求

要在Ubuntu 14.04 x64安装Docker，需要确保Ubuntu的版本是64位，而且内核版本需大于3.10版。

#### 1.1.1 检查Ubuntu的内核版本

```shell
# uname -r
3.13.0-55-generic
```

#### 1.1.2 更新系统，确保软件包列表的有效性

```shell
# apt-get update
```

#### 1.1.3 如果Ubuntu的版本不满足，还需升级Ubuntu

```shell
# apt-get -y upgrade
```

### 1.2 安装Docker

一旦以上需求都满足了，就可以开始安装Docker。Docker最早只支持Ubuntu，后来有了CentOS和其它RedHat相关的发布包。安装很简单，执行命令：

```shell
# apt-get -y install docker.io
```

> 注意不是docker, 而是docker.io

### 1.3 创建链接

创建软链接

```shell
 # ln -sf /usr/bin/docker.io /usr/local/bin/docker
 # sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
 ```

 > 这里我自己并没有执行第二条命令, 因为并不知道它做了什么, 而且也用不到.

### 1.4 检查Docker服务

要检查Docker服务的状态，执行以下命令，确保Docker服务是启动的。

```shell
# service docker.io status
docker.io start/running, process 14394
```

要把Docker以守护进程的方式运行，执行以下命令：（注意需先关闭Docker服务）

```shell
# docker -d &
```

### 1.5 Docker自启动服务

把Docker安装为自启动服务，让它随服务器的启动而自动运行，执行命令：

```shell
# update-rc.d docker.io defaults
```

通过这种方式安装的docker版本较低, 在`ubuntu14.04`, 内核版本为`4.2.0-27-generic`情况下, 得到的docker版本是`0.9.1`.

这不是最令人无奈的, 最令人无奈的是, `docker search`命令执行正常, `docker pull`会出错, 即使用了`daocloud`加速器也一样. 报错如下.

```shell
# docker pull centos:6
Invalid Registry endpoint: This does not look like a Registry server ("X-Docker-Registry-Version" header not found in the response
```

在网上得到的相同报错的情况都是出现在搭建docker私有仓库的时候, 由于https证书的问题造成的, 显然与我这种情况不符...只能另寻办法, 先把docker.io卸载掉吧.

```shell
# apt-get remove docker.io
```
------

按照`daocloud`中的[安装方法](https://dashboard.daocloud.io/nodes/new), 执行如下脚本, 将会得到较新版本的docker, 我的是`1.11.2`.

```shell
# curl -sSL https://get.daocloud.io/docker | sh
```

但是在执行`service docker status`时, 发现docker没有在service命令的管理之下.

```shell
# service docker status
status: Unknown job: docker
```

先说明下情况, 我所有的操作都是在root用户下执行的, 在普通用户下通过`sudo`执行`service`命令, **可以正常工作!**. 如果不通过`sudo`结果依然是`Unknown jon`.

```shell
general@generals:~$ service docker status
status: Unknown job: docker

general@generals:~$ sudo service docker status
[sudo] password for general:
docker stop/waiting
```

...是不是有点, 凌乱?
