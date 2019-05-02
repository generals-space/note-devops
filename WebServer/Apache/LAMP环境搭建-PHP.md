# LAMP环境搭建-PHP

```
#!/bin/bash

## 常用依赖
yum install -y \
libxml2 libxml2-devel \
libvpx libvpx-devel libjpeg libjpeg-devel \
libpng libpng-devel \
libXpm libXpm-devel t1lib t1lib-devel \
freetype freetype-devel gd gd-devel \
curl libcurl-devel \
zlib zlib-devel bzip2 bzip2-devel openssl openssl-devel \
libmcrypt libmcrypt-devel mhash mhash-devel mcrypt

## 编译选项
#### --with-mysql=mysqlnd表示使用php官方的mysql驱动, 所以编译php前不需要安装mysql
./configure \
--prefix=/usr/local/php \
--enable-pcntl --enable-mysqlnd --enable-opcache --enable-sockets \
--enable-sysvmsg --enable-sysvsem  --enable-sysvshm \
--enable-shmop --enable-zip --enable-ftp --enable-soap --enable-xml --enable-mbstring \
--disable-rpath --disable-debug --disable-fileinfo \
--with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
--with-pcre-regex --with-iconv --with-zlib --with-gd --with-xmlrpc --with-curl \
--with-mcrypt --with-openssl --with-mhash --with-imap-ssl

make && make install
```

### 编译选项

关于PHP源码编译应该首先了解的, 把它的`configure`选项分为两种:

- 一种是编译时选择开启或关闭的特性.

- 需要额外安装的模块与依赖.

根据这种原则, `configure`文件中的常用选项可以分为这4种情况.

1 . `--prefix`, `--with-config-file-path`这种关于php的`安装路径`, `配置路径`, `扩展路径`等;

除了`--prefix`在安装前必须指定, 其他的都可以在配置文件中指定其他路径.

2 . php语言内置特性, 使用configure中`--enable-*`选项开启或关闭.

这些选项应该是无法在php配置文件中修改的, 所以编译时应该准确指定, 不过默认值应该是官方推荐的比较好的选择, 除非有特别需要, 不必纠结这个.

3 . 安装时指定的依赖库(libxml2), 模块(mcrypt)等, 使用`--with-*`指定路径;

模块对于原生php语言来说不是必须的, 只是少了些额外功能而已, 但依赖库是必须要安装的, 比如libxml2, 这些是php本身的依赖, 如果没有这些, php是无法安装的.

4 . 配合使用的环境(apxs, mysql), 在configure文件中被称为`SAPI`, 应该是 **服务器应用编程接口**, 不过官网中这一节中大部分还是使用`--enable-*`开启或关闭的, 我自己把这些归为第2种情况.

关于这种情况, 如果php不是单纯的作为脚本执行, 而是需要处理http请求, 连接数据库等, 就需要apache有执行php程序的模块, 而php也需要有各种数据库的"驱动". 所以应该先安装apache与数据库, 再安装php. 其实也可以算上是一种模块.

### 扩展: 内置扩展与模块扩展

如网上所说, 一开始安装PHP的时候, 一般并不知道需要哪些扩展, 所以只有等到我们真正用到的时候才想办法去安装. 不过, 也会有些确定需要的扩展可直接编译进PHP环境.

这两者的区别是, 后者可以在php.ini配置文件中选择开启或者关闭, 而前者只能一直处于开启状态. 当然, 因为前者免去了模块查找, 加载等的时间, 速度会比后者快些; 而且通过后者安装的模块会出现在指定的模块路径中, 一般以.so结尾, 而前者不会.

### 安装扩展

关于模块源码

php源码包ext目录下有比较常用的依赖库与原生模块, 如openssl, zlib库, 还有curl, mcrypt模块等, 也可以去模块各自的官网上下载, 不过这两种都没有模块完整的依赖库(尤其是依赖库的依赖库...), 需要事先自行安装.

区别在于, 前者没有Makefile文件, 需要使用相同版本的php环境下的phpize工具建立php的外挂模块, 即只能为已经存在的php环境"添加"模块, 后者则是可以将模块编译到php环境内部.

其实如果对依赖库没有严格的版本限制, 直接使用yum安装各种依赖包更方便一些, 其他扩展可以在需要的时候再添加入php模块路径, 再在配置文件中开启即可.
