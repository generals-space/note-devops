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

## 2. [emerg] invalid host in upstream

### 问题描述

配置完`upstream`块, 启动或是检查时报错如下

```
$ nginx -t
nginx: [emerg] invalid host in upstream "172.16.3.132:8080/" in /usr/local/nginx/conf/nginx.conf:79
nginx: configuration file /usr/local/nginx/conf/nginx.conf test failed
```

### 原因分析

注意: upstream的标准写法是

```
upstream pool名称 {
  server IP:端口 参数;
}
```

其中`IP`前不可以加`http(s)://`前缀, 端口后不可以加`/`和任何后缀.

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

## 4. 400 Bad Request: The plain HTTP request was sent to HTTPS port

参考文章

1. [Nginx如何解决“The plain HTTP request was sent to HTTPS port”错误](https://www.centos.bz/2018/01/nginx%E5%A6%82%E4%BD%95%E8%A7%A3%E5%86%B3the-plain-http-request-was-sent-to-https-port%E9%94%99%E8%AF%AF/)

情景描述

使用阿里云提供的ssl证书配置nginx的https接口, 同时保留了80的普通http接口. 配置类似如下

```
server{
    listen 80;
    listen 443 ssl;
    ssl on;
    ## xxx
}
```

当用户访问`https://`时, 一切正常.

但访问`http://`时, 页面就会报上述错误.

参考文章1中的分析一针见血: 客户试图通过HTTP访问你的网站, 但Nginx总是使用SSL交互, 但原来的请求（通过端口80接收）是普通的HTTP请求, 于是会产生错误.

解决办法

要么把上述的`ssl on;`改成`ssl off;`, 要么把http与https的server块分开处理.