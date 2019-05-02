# Nginx+Tomcat+Memcached搭建Session缓存服务器

## 1.实验环境

实际只用1台阿里云服务器, 部署1个Nginx, 3个Tomcat, 1个Memcached;

- 系统版本: 阿里云CentOS 7

- Nginx: 1.9.3

- Tomcat: 8.0

- Memcached:1.4.15

环境准备好后进行接下来的步骤.

## 2. Nginx+Tomcat实现负载均衡与动静分离

Nginx接受前端请求, 如果是静态文件, 则Nginx自行响应, 如果是jsp或do等servlet请求, 则将其转发给后端3台Tomcat服务器.

### 2.1 后端Tomcat设置

首先, 设置3台Tomcat分别监听不同端口, 在`$TOMCAT/conf/server.xml`文件中更改Connector的端口设置.

```xml
<Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
```

port值默认为`8080`, 将3台Tomcat分别更改为tomcat1监听`8080`, tomcat2监听`8180`, tomcat3监听`8280`.

当然, shutdown端口也要设置为不同的, 否则关闭tomcat的时候会出问题.

```xml
<Server port="8005" shutdown="SHUTDOWN">
```

port值默认为`8005`, 将3台Tomcat分别更改为tomcat1监听`8005`, tomcat2监听`8105`, tomcat3监听`8205`.

### 2.2 前端Nginx设置

然后设置Nginx的转发规则.

```
##Tomcat后端服务器池, 用于接收来自Nginx转发过来的请求
upstream backend_pool {
        server localhost:8080 max_fails=3 fail_timeout=60s weight=1;
        server localhost:8180 max_fails=3 fail_timeout=60s weight=1;
        server localhost:8280 max_fails=3 fail_timeout=60s weight=1;
}
server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  www.example.com;

        ##将root属性定位在某一个tomcat的webapps/ROOT目录下, 
        ##因为新安装的tomcat只有它默认的欢迎页,
        ##实际应用中应将此目录定位在静态文件的根目录
        root         /opt/tomcat1/webapps/ROOT;
        index   index.jsp

        include /etc/nginx/default.d/*.conf;
       
        location ~ .*\.(css|js|jpg|bmp|png|swf)$ {
                ##这里的root属性将继承父节点的root值
                ##root /opt/tomcat1/webapps/ROOT;
                expires 30d;
        }
        ##不明确指定jsp与do请求才转发给tomcat,
        ##因为有很多java程序中没有对servlet后缀进行标识, 因而看起来像是一个目录.
        ##所以将一些可以想到的静态文件由Nginx处理, 其他的都转发给后端Tomcat
        ##location ~ .*\.(jsp|do)$ {
        location / {
            proxy_pass   http://backend_pool;
            proxy_set_header HOST $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}
```

这样, 启动Nginx与Tomcat, 访问`http://你的IP`, 多次刷新, 如果都能看到Tomcat的欢迎页, 并且每个Tomcat的`logs/localhost_access*`文件中可以看到来访日志, 就说明负载均衡配置成功.

或者你也可以在每个`Tomcat/webapps/ROOT/index.jsp`加上唯一的特殊标识, 这样每次刷新就能在首页上看到区别了. 试验的时候是每2次请求就转到下一个tomcat, 一直循环.

## 3. Tomcat+Memcached配置Session服务器

简单的session话, 只要在nginx的upstream块中设置`ip_hash`标记就可以了, nginx会将来自同一个IP的用户请求转发给同一个tomcat, 这样就不会出现session丢失. 但是缺点多多, 还是自行搭建session服务器更有格调.

### 3.1 

首先准备一个能够设置session的java程序, 我这里就不贴代码了, 我自己对Java语言也不太熟悉.

简单说来就是两个页面: `index.jsp`与`welcome.jsp`, 这两个页面都会对当前的session进行检查.

- `index.jsp`检测如果当前存在一个名为`username`的`session`, 就自动跳转到`welcome.jsp`页面, 否则显示登录框与登录按钮;

- `welcome.jsp`也会检测如果当前存在一个名为`username`的`session`, 就显示"欢迎, $username"字符串与注销按钮, 否则跳转到`index.jsp`;

当然后台需要编写servlet完成登录与注销时创建与销毁session的功能.

这样, 在访问index页面的时候, 点击登录按钮, 请求就可能发送到与响应当前index页面的不同的tomcat上, 所以在重复刷新过程中, 有时会跳转到`welcome`, 有时会显示`index`页面, 无法实现session共享. (呃, 这是理想状态, 实际上测试的时候只有偶尔登录之后跳转到welcome, 然后就一直停留在index页面, 大部分是根本没有出现过welcome页面, 就是说出现了session丢失, 网上说可能是`proxy_cookie_path`的问题, 还没有弄明白, 留个疑问).

> PS

> 这里有两个前端方面的tips, 好久不写前端, 乍一写有很多东西都忘记了.

> 1. 前端通过ajax发出验证请求, 后端验证成功后无法通过`response.sendRedirect`使前端页面跳转, 只能通过前端ajax的回调函数, `location.href = "指定地址"`手动跳转;

> 2. jquery的`$("目标元素").click(function(){})`需要包含在`$(document).ready(function(){jquery方法});`中, 否则无法将监听事件绑定在目标元素上;

### 3.2

`memcached`的启动非常简单, 而且session服务器的配置主要是对tomcat的`jar`包与`conf/*.xml`进行设置.

网上大部分的解决方案都是关于`memcached-session-manager`的. 貌似原来在google code上, 现在在github上也有其代码与文档了, 可以在github上搜索一下(或者点击[这里](https://github.com/magro/memcached-session-manager)).

在其readme的`Installation and Configuration`小节中有实际的安装与配置步骤(或者点击[这里](https://github.com/magro/memcached-session-manager/wiki/SetupAndConfiguration)).

其中关于序列化方案什么的有些高端, 初次配置也没考虑那么多, 听说`kryo`性能比较高, 就以此来实验.

------

我们需要下载很多jar包, 官方给出了maven下载的配置方案, 貌似很简单(同学试了一下, 简直完美), 但我不会用maven, 只能手动下载. 遇到的问题主要是jar包的版本的匹配与依赖. 官方给出的下载链接点进行会有许多版本供你选择, 其中2, 3, 4的版本必须要一致(就是2, 3中的`$version`变量), 我选择的都是`1.9.1`.

下载列表为:

1. spymemcached-2.11.1.jar

2. memcached-session-manager-${version}.jar

3. memcached-session-manager-tc8-${version}.jar(我所用的tomcat是8.0, 所以是tc8, 可以根据你的版本自行选择, tomcat的6,7,8 都有的);

4. msm-kryo-serializer

5. kryo-serializers-0.34

6. kryo-3.x(3点多版本的都无所谓了).

7. minlog

8. reflectasm

9. asm-5.x(这个也是5点多版本的都无所谓的)

按照官方文档上说的, 1-3是需要放置在每个`tomcat/lib`目录中的, 4-9是要放在每个应用程序的`WEB-INF/lib`中的, 当然我感觉都放在`tomcat/lib`中也可以.

------

**PS.**

1 . 这里有个雷让我踩了, kryo我选的是3.0.3, 点进行直接下载的kryo-3.0.3.jar, 但是tomcat重启的时候(在配置完成之后)报错

```
28-Feb-2016 17:04:58.154 SEVERE [localhost-startStop-1] org.apache.catalina.core.StandardContext.startInternal The s
ession manager failed to start
 org.apache.catalina.LifecycleException: Failed to start component [de.javakaffee.web.msm.MemcachedBackupSessionMana
ger[]]
```

这是因为**kryo也有自己的依赖包**, 在3.0.3目录下还有一个`kryo-3.0.3-all.zip`文件, 解压之后里面有个`lib`目录, 里面是kryo的依赖包, 也将它们拷贝到`WEB-INF/lib`下吧, 主要是`objenesis-2.1.jar`.

2 . 第2个雷我同学踩了, 他使用官方文档提供的maven下载的jar包, 全部放在`WEB-INF/lib`下, 结果出错了, 问题很多方面.

首先貌似**本文3.2节里1-3的jar包必须放在tomcat/lib目录下, 其他的可以放在WEB-INF/lib下, 否则web访问时程序加载不出来**;

另外, maven下载的有个jar包错了, 关于第9个包, maven方案下载的是`asm-5.0.3-sources.jar`, 这样可能会出现如下的错误:

```
java.lang.NoClassDefFoundError: org/objectweb/asm/ClassWriter
```

### 3.3

接下来是tomcat的配置文件. 编辑`$TOMCAT/conf/context.xml`文件, 或是工程目录中的`META-INF/context.xml`文件, 不建议直接编辑`$TOMCAT/conf/server.xml`.

```xml
<Context>
  ...
  <Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
    memcachedNodes="n1:127.0.0.1:11211"
    sticky="false"
    sessionBackupTimeout="1000"
    transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
    />
</Context>
```

其中memcachedNodes是你的memcached节点, 我只有一个运行在本地的memcached, 所以只写了一个, 如果有多个session服务器, 可以用如下格式, 不过初次配置的话还是不要自找麻烦的好.

```
memcachedNodes="n1:host1.yourdomain.com:11211,n2:host2.yourdomain.com:11211"
```

### 3.4

这样基本就配置好了, 确保memcached已经启动, 重启各个tomcat, 如果catalina.out日志中输出类似如下结果的话, 我想应该就是成功了.

```
28-Feb-2016 17:18:48.199 INFO [localhost-startStop-1] de.javakaffee.web.msm.MemcachedSessionService.startInternal --------
-  finished initialization:
- sticky: false
- operation timeout: 1000
- node ids: [n1]
- failover node ids: []
- storage key prefix: null
--------
```

两次访问登录页面, 登录完成之后多次刷新依旧只显示`welcome.jsp`页面, 这样就搞定了.