# Apache连接Tomcat-JK与AJP模式.md

参考文章

1. [Apache HTTP Server 与 Tomcat 的三种连接方式介绍](https://www.ibm.com/developerworks/cn/opensource/os-lo-apache-tomcat/)

## 1. JK

这是最常见的方式, 你可以在网上找到很多关于配置JK的网页, 当然最全的还是其官方所提供的文档. JK本身有两个版本分别是1和2, 目前1最新的版本是`1.2.19`, 而版本2早已经废弃了, 以后不再有新版本的推出了, 所以建议你采用版本1.

JK 是通过 AJP 协议与 Tomcat 服务器进行通讯的, Tomcat 默认的 AJP Connector 的端口是 8009. JK 本身提供了一个监控以及管理的页面 jkstatus, 通过 jkstatus 可以监控 JK 目前的工作状态以及对到 tomcat 的连接进行设置, 如下图所示:

![](https://gitee.com/generals-space/gitimg/raw/master/4ced3abe58352b472bb9843bd7223f7c.jpg)

图1:监控以及管理的页面 jkstatus

在这个图中我们可以看到当前JK配了两个连接分别到 8109 和 8209 端口上, 目前 s2 这个连接是停止状态, 而 s1 这个连接自上次重启后已经处理了 47 万多个请求, 流量达到 6.2 个 G, 最大的并发数有 13 等等. 我们也可以利用 jkstatus 的管理功能来切换 JK 到不同的 Tomcat 上, 例如将 s2 启用, 并停用 s1, 这个在更新应用程序的时候非常有用, 而且整个切换过程对用户来说是透明的, 也就达到了无缝升级的目的. 关于 JK 的配置文章网上已经非常多了, 这里我们不再详细的介绍整个配置过程, 但我要讲一下配置的思路, 只要明白了配置的思路, JK 就是一个非常灵活的组件.

JK 的配置最关键的有三个文件, 分别是

- httpd.conf: Apache 服务器的配置文件, 用来加载 JK 模块以及指定 JK 配置文件信息

- workers.properties: 到 Tomcat 服务器的连接定义文件

- uriworkermap.properties: URI 映射文件, 用来指定哪些 URL 由 Tomcat 处理, 你也可以直接在 httpd.conf 中配置这些 URI, 但是独立这些配置的好处是 JK 模块会定期更新该文件的内容, 使得我们修改配置的时候无需重新启动 Apache 服务器.

其中第2,3个配置文件名都可以自定义. 下面是一个典型的 httpd.conf 对 JK 的配置

```
# (httpd.conf)
# 加载 mod_jk 模块
LoadModule jk_module modules/mod_jk.so

#
# Configure mod_jk
#

JkWorkersFile conf/workers.properties
JkMountFile conf/uriworkermap.properties
JkLogFile logs/mod_jk.log
JkLogLevel warn
```

接下来我们在 Apache 的 conf 目录下新建两个文件分别是 workers.properties, uriworkermap.properties. 这两个文件的内容大概如下

```
#
# workers.properties
#


# list the workers by name

worker.list=DLOG4J, status

# localhost server 1
# ------------------------
worker.s1.port=8109
worker.s1.host=localhost
worker.s1.type=ajp13

# localhost server 2
# ------------------------
worker.s2.port=8209
worker.s2.host=localhost   #可以指定不同的服务器哦
worker.s2.type=ajp13
worker.s2.stopped=1   #这是说s2默认不使用, 当s1挂掉时再开启么?

worker.DLOG4J.type=lb
worker.retries=3
worker.DLOG4J.balance_workers=s1, s2
worker.DLOG4J.sticky_session=1

worker.status.type=status
```

以上的 workers.properties 配置就是我们前面那个屏幕抓图的页面所用的配置. 首先我们配置了两个类型为 ajp13 的 worker 分别是 s1 和 s2, 它们指向同一台服务器上运行在两个不同端口 8109 和 8209 的 Tomcat 上. 接下来我们配置了一个类型为 lb（也就是负载均衡的意思）的 worker, 它的名字是 DLOG4J, 这是一个逻辑的 worker, 它用来管理前面配置的两个物理连接 s1 和 s2. 最后还配置了一个类型为 status 的 worker, 这是用来监控 JK 本身的模块. 有了这三个 worker 还不够, 我们还需要告诉 JK, 哪些 worker 是可用的, 所以就有 worker.list = DLOG4J, status 这行配置.

接下来便是 URI 的映射配置了, 我们需要指定哪些链接是由 Tomcat 处理的, 哪些是由 Apache 直接处理的, 看看下面这个文件你就能明白其中配置的意义

```
/*=DLOG4J
/jkstatus=status

!/*.gif=DLOG4J
!/*.jpg=DLOG4J
!/*.png=DLOG4J
!/*.css=DLOG4J
!/*.js=DLOG4J
!/*.htm=DLOG4J
!/*.html=DLOG4J
```

相信你已经明白了一大半了: 所有的请求都由 DLOG4J 这个 worker 进行处理, 但是有几个例外: /jkstatus 请求由 status 这个 worker 处理. 另外这个配置中每一行数据前面的感叹号是什么意思呢? 感叹号表示接下来的 URI 不要由 JK 进行处理, 也就是 Apache 直接处理所有的图片, css 文件, js 文件以及静态 html 文本文件.

通过对 workers.properties 和 uriworkermap.properties 的配置, 可以有各种各样的组合来满足我们前面提出对一个 web 网站的要求. 您不妨动手试试!

## 3. ajp_proxy

`ajp_proxy`连接方式其实跟普通`http_proxy`方式一样, 都是由`mod_proxy`所提供的功能, 配置也是一样. 不过是协议不同而已, 普通http转发是http协议, `ajp_proxy` 只需要把`http://`换成 `ajp://`, 不过连接的是Tomcat的`AJP Connector`所在的端口, 所以后端tomcat节点需要解开AJP的注释. 上面例子的配置可以改为:

```xml
ProxyPass /images !
ProxyPass /css ! 
ProxyPass /js !

ProxyPass / balancer://example/
<Proxy balancer://example/>
BalancerMember ajp://server1:8080/
BalancerMember ajp://server2:8080/
BalancerMember ajp://server3:8080/
</Proxy>
```

采用 proxy 的连接方式, 需要在 Apache 上加载所需的模块, `mod_proxy`相关的模块有

- `mod_proxy.so`

- `mod_proxy_connect.so`

- `mod_proxy_http.so`

- `mod_proxy_ftp.so`

- `mod_proxy_ajp.so`

其中`mod_proxy_ajp.so`只在Apache 2.2.x 中才有. 

如果是采用`http_proxy`方式则需要加载`mod_proxy.so`和` mod_proxy_http.so`; 

如果是`ajp_proxy`则需要加载`mod_proxy.so`和`mod_proxy_ajp.so`这两个模块.

## 4. 三者比较

相对于 JK 的连接方式, 后两种在配置上是比较简单的, 灵活性方面也一点都不逊色. 但就稳定性而言就不像 JK 这样久经考验, 毕竟 Apache 2.2.3 推出的时间并不长, 采用这种连接方式的网站还不多, 因此, 如果是应用于关键的互联网网站, 还是建议采用 JK 的连接方式.