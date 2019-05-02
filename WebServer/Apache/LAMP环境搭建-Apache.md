#LAMP环境搭建-Apache#

很好的参考文档, 两者其实是同一篇. 这里只写安装思路与过程, 下面两篇还讲述了apache的运行原理与配置详解.

[http://sweetpotato.blog.51cto.com/533893/1662934?utm_source=tuicool&utm_medium=referral]()

[http://www.tuicool.com/articles/3a2QF3]()

##1. 写在前面##

系统环境：CentOS 6.4-x86_64
Apache: 2.2 (apache官网只提供最新包, 无法下载旧版的源码包, 2.2各版本之间应该不会有较大区别).

使用yum安装apache时会自动安装其依赖包, 包括`apr`, `apr-util`, `pcre`等(还有`mailcap`什么的, 不过并不是必须的), 编译安装时也需要至少这个3个包.

### yum安装依赖

可以使用yum安装依赖包, 然后编译apache时就不需要指定`--with-pcre`, `--with-apr`与`--with-apr-util`的路径了. 不过很可能会出现版本不匹配的问题, 所以最好统一使用源码安装

```shell
yum install apr apr-devel apr-util apr-util-devel pcre pcre-devel
```

### 源码安装依赖

高端一点的方式是源码安装依赖

`apr`与`apr-util`在[这里](http://apr.apache.org/)下载. 注意: 是`Releases`这一项中的, 而不是`Source`.(咳, 直接在[这里](http://apr.apache.org/download.cgi)吧, 方便一点)

两者configure时只需要指定`--prefix`(当然也可以不指定). 因为apr-util依赖于apr, 前者安装时需要指定后者的路径(`--with-apr`), 所以应该优先安装`apr`.

`pcre`的[官网](http://www.pcre.org/), 貌似现在有`pcre2`了, 不知道其向前兼容性怎样, 还是直接使用`pcre`吧. 选择最新最稳定的就可以了. 这个也是只需要指定`--prefix`就可以了.

### 安装 apache

apache的configure选项很多, 需要对apache也有很深刻的了解才可以准确配置. 引用网上的一个安装步骤:

```shell
$ tar xf httpd-2.2.31.tar.bz2
$ cd httpd-2.2.31
$ ./configure \
--prefix=/usr/local/apache \
--sysconfdir=/etc/httpd-2.2.31 \
--enable-so --enable-ssl --enable-cgi --enable-rewrite --enable-deflate \
--with-z --with-pcre --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util \
--enable-modules=most --enable-mpms-shared=all \
--with-mpm=event
$ make && make install

# 各编译参数详解
--prefix：#安装路径
--sysconfdir：#配置文件路径
--enable-ssl：#支持SSL/TLS，可以实现https访问
--enable-cgi：#支持CGI脚本（默认对非线程的MPM模式开启）
--enable-rewrite：#启用Rewrite功能
--enable-deflate：#支持压缩
--with-z：#使用指定的zlib库，不指定路径会自动寻找
--with-pcre：#使用指定的PCRE库，不指定路径会自动寻找
--with-apr：#指定apr安装路径
--with-apr-util：#指定apr-util安装路径
--enable-modules：#支持动态启用的模块，可选参数有“all”，“most”，“few”，“reallyall”
--enable-so：#DSO兼容，DSO=Dynamic Shared Object，动态共享对象，可实现模块动态生效
--enable-mpms-shared：#支持动态加载的MPM模块，可选“all”
--with-mpm：#设置默认启用的MPM模式
```

Apache安装目录结构

```shell
/usr/local/apache/
├── bin    #存放启动或关闭httpd的脚本文件
├── build
├── cgi-bin  #cgi程序文件的存放目录
├── error    #发生服务器端错误时返回给客户端的错误页面
│   └── include   
├── htdocs  #Web页面所在的目录
├── icons   #存放httpd的图标文件
│   └── small
├── include  #存放头文件
├── logs     #httpd的日志文件
├── man      #帮助手册
│   ├── man1
│   └── man8
├── manual  #httpd的配置手册
│   ├── developer
│   ├── faq
│   ├── howto
│   ├── images
│   ├── misc
│   ├── mod
│   ├── platform
│   ├── programs
│   ├── rewrite
│   ├── ssl
│   ├── style
│   │   ├── css
│   │   ├── lang
│   │   ├── latex
│   │   ├── scripts
│   │   └── xsl
│   │       └── util
│   └── vhosts
└── modules  #存放httpd的模块

```

###一些善后工作###

以前从来没有考虑过这个, 参考文章给了我很大提醒. 除了修改配置文件中的pid/log路径, 修改PATH变量还有这几个步骤.

####导出头文件####

```shell
ln -sv /usr/local/apache/include /usr/local/include/httpd
```

####导出man手册####

编辑/etc/man.config, 添加入:

```shell
MANPATH /usr/local/apache/man
```

####编写服务脚本####

因为是编译安装, 不会自动生成服务脚本(`service httpd start`的那个`httpd`), 另外还要给其添加执行权限

一般是编辑为`/etc/rc.d/init.d/httpd`文件, 文件内容可以参考同目录下的其他服务脚本或者直接从使用yum安装httpd的此目录下copy一个. 这里就不抄了.
