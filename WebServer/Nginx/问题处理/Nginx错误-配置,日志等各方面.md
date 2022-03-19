# Nginx错误-配置,日志等各方面

## 1. nginx: [emerg] getpwnam("www") failed

[参考文章]

[nginx安装 nginx: \[emerg\] getpwnam(“www”) failed 错误](http://my.oschina.net/u/1036767/blog/210443)

### 问题描述

nginx源码安装完成, 第一次启动出现这个错误

### 原因分析

编译选项中指定了nginx的执行用户为`xxx`, 但是这个用户没有被创建, nginx.conf中的`user`指令也没有修改.

### 解决方法

创建指定用户, 将nginx.conf中的 `user`指令改成此用户.

```shell
useradd -M nginx -s /sbin/nologin
```

## 3.

参考文章

1. [nginx: [alert] version 1.4.0 of nginx.pm is required, but 1.2.0 was found](http://blog.csdn.net/longxibendi/article/details/50813789)

```
nginx: [alert] version 1.10.2 of nginx.pm is required, but 1.10.1 was found
```

问题描述: 之前用源码装了一下nginx, 后来想了想, CentOS自带的nginx版本已经够新了, 源码安装没什么优势, 于是把源码装的删掉了. 但是在启动nginx时报上述错误.

参考文章中也说升级的时候可能出现这个问题.

可以看到是因为两次安装的nginx版本不同, 安装过程中肯定还有什么文件放置在了指定位置, 删除的时候没删干净.

`find nginx.pm`发现, 这个perl文件, 在`make install`的时候, 就会安装, 如果不指定安装目录, 这个文件会默认安装到`/usr/local/lib64/perl5/nginx.pm`. 
而nginx.pm里面记录了nginx的版本号. 所以, 如果启动nginx的时候, 运行的nginx与nginx.pm版本号不一致就有问题, 特别是升级nginx, 或者一台机器上部署了多个nginx. 

删掉这个文件, 再启动新的nginx就没问题了.

> 编译选项` --with-perl_modules_path=/home/webserver/nginx3/perl`可以指定这个文件的安装路径.
