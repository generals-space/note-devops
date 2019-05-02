# Apache+Tomcat部署(mod_jk)

## 1. 实验环境

- 系统平台: CentOS 6.4

- Apache: 2.4.17

- Tomcat: 8.0.24, 使用二进制发布版即可.

- Tomcat Connectors (mod_jk): 1.2.41, 官网在[这里](http://tomcat.apache.org/download-connectors.cgi)

> 注意: 因为`jk`模块需要编译安装, 编译选项需要用到Apache的`apxs`, 所以Apache也需要用源码安装(我在用yum安装apache的Linux环境中没找到apxs可执行文件).

## 2. 编译安装

Apache的编译选项只需要`--prefix=/usr/local/apache2`与`--enable-so`(至于依赖软件的路径指定, 请参考...)

`mod_jk`的安装要在解压包目录的`native`目录下, 编译选项只需要`--with-apxs=/usr/local/apache2/bin/apxs`(**此处和编译php不一样, 不是`apxs2`**). `make && make install`安装完成后会在Apache的安装目录的modules目录下添加`mod_jk.so`文件. 如果没有, 则需要手动复制`native/apache-2.0/mod_jk.so到/usr/local/apache2/modules`目录下.

## 3. 文件配置

在Apache的`conf`目录下新建`mod_jk.conf`, `workers.properties`, `uriworkermap.properties`.

其中第一个是对jk模块的配置文件, jk模块需要后面两个文件配置具体参数, 第二个是指定连接/转发进程, 第三个将指定转发规则. 具体配置如下:

1. 首先, 在`httpd.conf`中加载jk模块, 并包含jk模块的配置文件

```conf
LoadModule jk_module modules/mod_jk.so
Include /usr/local/apache2/conf/mod_jk.conf
```

2. 编辑mod_jk.conf, 添加模块所选的配置文件

```conf
#
# Configure mod_jk
#

JkWorkersFile conf/workers.properties
JkMountFile conf/uriworkermap.properties
JkLogFile logs/mod_jk.log
JkLogLevel warn
```

3. 编辑workers.properties, 配置连接/转发"进程"

```conf
# Defining a worker named "s1" and of type ajp13
worker.list=s1

# Set properties for s1
worker.s1.type=ajp13
worker.s1.host=localhost    #可以是IP, 但不用加http://, 否则jk无法解析
worker.s1.port=8009
```

4. 编辑uriworkermap.properties, 配置转发规则

```conf
/*=s1    //将所有请求交给s1处理
//下面的配置是说, 对这些静态文件的请求就不用转发给Tomcat了, 由Apache直接处理
!/*.gif=s1
!/*.jpg=s1
!/*.png=s1
!/*.css=s1
!/*.js=s1
!/*.htm=s1
!/*.html=s1
```

5. 要确保Apache的`DocumentRoot`与Tomcat的`Context`字段都指向目标项目目录哦, 不然访问的目标都不一样.

6. 要确保Tomcat打开对`ajp`端口的监听, 默认为`8009`, 在`Tomcat/conf/server.xml`中, 默认被注释掉了, 将注释去掉即可.

7. 启动Tomcat, Apache(当然也有可能要启动MySQL), 直接访问`http://localhost`, 查看是否与访问http://localhost:8080结果相同.

## 4. 注意

有些web项目不允许直接访问静态文件, 如dotcms, 网页中的链接与网站目录结构并不相符, 这样所有的请求都需要经过Tomcat解析, uriworkermap.properties文件中只需要保留/*=s1这一行即可.

不过, 这样的话Apache只起到了代理转发的作用, 无法对静态文档的请求快速响应.

关于JK模块的更详细更高级的配置, 参考官方文档:

http://tomcat.apache.org/connectors-doc/

Apache与Tomcat的整合还有其他方式, 