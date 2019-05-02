# LAMP环境搭建

## 1. 前言

关于这3者(apache, php, mysql)的关系, 源码安装顺序一般为 **apache->mysql->php**. 因为apache如果需要执行php脚本(即将http请求交由php处理), 需要一个mod_php.so的模块作为"驱动"; 而php语言如果要连接数据库, 也需要对应的数据库"驱动", 这两个驱动都是需要php在编译时生成的, 所以需要apache与mysql安装完成的情况下安装php.

详细一点就是, apache编译生成的bin/apxs文件是php的configure选项`--with-apxs2`所需的, 否则无法生成mod_php.so模块; php也可以根据需要决定是使用mysql自带的连接驱动还是使用pdo-mysql作为数据库驱动, 如果是前者, 则不需要指定任何关于mysql的选项, 如果是后者, 则需要安装php-pdo-mysql, 指定`--with-pdo-mysql`选项.

------

作死场景--apache与mysql使用yum安装, php使用源码编译.

```shell
yum install httpd httpd-devel
yum install mysql-server mysql-client mysql-community-libs
```

正常情况下, 使用yum安装LAMP时, 安装php就会顺便安装apache的mod_php.so. 现在使用源码编译php了, 单纯的httpd并没有安装`apxs`这个文件, 所以在编译php之前还要安装apxs, 它就在`httpd-devel`包中. 这样在指定php的`--with-apxs2`选项时就需要`whereis apxs`确定它的路径了, 一般在`/usr/sbin/apxs`.

完成后apache的模块目录中应该会多一个php的模块, 接下来需要在apache的配置文件中开启它, 还要打开对php文件格式的支持.

```shell
LoadModule php5_module modules/libphp5.so
AddType application/x-httpd-php .php
```

------
