# Tomcat配置文件理解

## 1. 配置文件理解

与`nginx`不同, `tomcat`没有`master`与`worker`进程的区别, 它只有一个进程. 

```xml
<Server port="8005" shutdown="SHUTDOWN">

  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" />
    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />

    <Engine name="Catalina" defaultHost="localhost">
        <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm" resourceName="UserDatabase"/>
        </Realm>

        <Host name="localhost"  appBase="webapps" unpackWARs="true" autoDeploy="true">

            <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs" prefix="localhost_access_log" suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" />
        </Host>
    </Engine>
  </Service>
</Server>
```

```conf
http{
    server{
        listen ;
        server_name ;
        location /{
            root ;
        }
    }
}
```

在`$TOMCAT/conf/server.xml`文件中, `<Server></Server>`标签的作用与`nginx.conf`中`http`字段的作用相似, 相当于一个tomcat实例, 控制tomcat进程的启停. 在这两者的作用域内, 配置参数都是相当于整个实例全局的. 并且**两者都是唯一的, 不可有多个`<Server></Server>`标签或多个`http`字段**.

`<Connector/>`标签类似于`nginx.conf`中的`listen`字段, 可以设置监听端口, 协议(`http` or `ssl`)等参数.

`<Host></Host>`标签可以设置虚拟主机名称(`server_name`字段), web工程路径(`root`字段), 是否自动解压部署等操作.

需要注意的是, 在tomcat里, `Connector`与`Host`的关系是并列的, 甚至`Connector`是在`Host`标签之前定义的, 而不是像`nginx.conf`文件中那样, 一个`server`块相当于一个虚拟主机, 内层再定义端口及虚拟主机的名称. 但是`<Service></Service>`标签将这两者都包裹起来, 组成一个完成的虚拟主机定义块.

另外还有tomcat/conf/context.xml. 从层次上来说, context标签为host的子标签. 像nginx.conf中`server`块下的`root`字段了. 可以看作javaWeb工程实例配置, 指定工程目录的存放路径(`root`字段)与访问路径(`location`字段), 工程目录存放路径可以以`host`字段为基准做相对路径, 也可以脱离host指定的根路径另外指定绝对路径, 同nginx有很多相似之处.

## 2. 虚拟主机配置

参考文章

[Tomcat的Server.xml虚拟主机和虚拟目录的配置](https://my.oschina.net/u/1468119/blog/208437)

在`server.xml`中`<Host></Host>`标签的同级位置增加`<Host></Host>`标签, `name`值取虚拟主机地址; `appBase`指向目标工程路径, 可以是绝对路径, 也可以是以`$TOMCAT_HOME`为基准的相对路径, 但不管哪一种, `appBase`所指向的目录下, 都需要存在`ROOT`目录, 而目标工程文件必须放置在`ROOT`目录下.

```xml
        <Host name="tomcat.generals.space"  appBase="/home/general"
                unpackWARs="true" autoDeploy="true">
        </Host>
```

这样, 访问`tomcat.generals.space`, 就会得到来自`/home/general`下的响应.

那如果想访问一个未定义过的虚拟主机地址, 那会访问到哪一个虚拟主机呢? 比如`a.generals.space`也指向tomcat服务器, 但`server.xml`中并没有此虚拟主机的配置.

结果需要看`<Host></Host>`标签所在的父标签`<Engine></Engine>`标签的`defaultHost`属性所示, 它可以取其下任意`<Host></Host>`子标签的`name`属性值, 决定了访问一个不存在的虚拟主机时将访问到哪一个工程.

> 注意: 如果`defaultHost`属性不存在, 那么当访问一个不存在的虚拟主机时, 将会得到404错误. 

## 3. 日志配置

参考文章

[Tomcat访问日志浅析](http://blog.csdn.net/yaerfeng/article/details/40340981)

[Tomcat日志设定](http://blog.csdn.net/lk_cool/article/details/4561306/)

tomcat日志信息分为两类:

- 访问日志，记录访问的时间, IP, url等相关信息。

- 运行时日志，主要记录运行的一些信息，尤其是一些异常错误日志信息 。

### 3.1 访问日志

访问日志一般写在`<Host></Host>`标签中, 添加`<Valve>`标签. 可以指定日志路径, 日志文件名, 格式等. 不同虚拟主机可以单独指定各自的日志配置.

```xml
      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
            <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
                prefix="localhost_access_log" suffix=".txt"
                pattern="%h %l %u %t &quot;%r&quot; %s %b" />
      </Host>

```

`pattern`属性指定当前虚拟主机所配置的日志格式, 除了在此属性中直接指定格式外, 还可以指定`common`与`combined`这两个别名, 这是tomcat中两种预先定义的日志格式. 它们的值分别为

- common: %h %l %u %t "%r" %s %b

- combined: %h %l %u %t "%r" %s %b "%{Referer}i" "%{User-Agent}i"

关于日志变量与其含义, 可以参照[tomcat官方文档](http://tomcat.apache.org/tomcat-6.0-doc/config/valve.html#Access_Log_Valve)

------

常用日志变量

- %a – 远程主机的IP, 即访问者的IP

- %A – tomcat服务器的本机IP

- %b – 发送字节数，不包含HTTP头，0字节则显示 '-'

- %B – 发送字节数，不包含HTTP头(看tomcat的解释，没看出来与`b%`的区别...)

- %h – 远程主机名 (Remote host name)

- %H – 请求的具体协议，HTTP/1.0 或 HTTP/1.1 (Request protocol)

- %l – 远程用户名，始终为 ‘-’ (Remote logical username from identd (always returns ‘-’))

- %m – 请求方式，GET, POST, PUT (Request method)

- %p – 本机端口 (Local port)

- %q – 查询串 (Query string (prepended with a ‘?’ if it exists, otherwise an empty string)

- %r – HTTP请求中的第一行 (First line of the request)

- %s – HTTP状态码 (HTTP status code of the response)

- %S – 用户会话ID (User session ID)

- %t – 访问日期和时间 (Date and time, in Common Log Format format)

- %u – 已经验证的远程用户 (Remote user that was authenticated

- %U – 请求的URL路径 (Requested URL path)

- %v – 本地服务器名 (Local server name)

- %D – 处理请求所耗费的毫秒数 (Time taken to process the request, in millis)

- %T – 处理请求所耗费的秒数 (Time taken to process the request, in seconds)

另外还可以将cookie, 客户端请求中带的HTTP头(incoming header), 会话(session)或是ServletRequest中的数据都写到Tomcat的访问日志中，可以用下面的语法来引用。

- %{xxx}i – 记录客户端请求中带的HTTP头xxx(incoming headers)

- %{xxx}c – 记录特定的cookie xxx

- %{xxx}r – 记录ServletRequest中的xxx属性(attribute)

- %{xxx}s – 记录HttpSession中的xxx属性(attribute)

注意看预定义格式中`combined`的日志格式`%{Referer}i`与`%{User-Agent}i`.

### 3.2 运行时日志

Tomcat日志分为下面５类(访问日志不在其中, 一般访问日志带有'access'标记)：

- catalina

- localhost

- manager

- host-manager

- admin(在日志配置文件中并没有见到此字段)

每类日志的级别分为如下7种：

SEVERE (highest value) > WARNING > INFO > CONFIG > FINE > FINER > FINEST (lowest value).

修改日志级别可以在`$TOMCAT_HOME/conf/logging.properties`中, 如下.

```ini
1catalina.org.apache.juli.AsyncFileHandler.level = FINE
1catalina.org.apache.juli.AsyncFileHandler.directory = ${catalina.base}/logs
1catalina.org.apache.juli.AsyncFileHandler.prefix = catalina.

2localhost.org.apache.juli.AsyncFileHandler.level = FINE
2localhost.org.apache.juli.AsyncFileHandler.directory = ${catalina.base}/logs
2localhost.org.apache.juli.AsyncFileHandler.prefix = localhost.

3manager.org.apache.juli.AsyncFileHandler.level = FINE
3manager.org.apache.juli.AsyncFileHandler.directory = ${catalina.base}/logs
3manager.org.apache.juli.AsyncFileHandler.prefix = manager.

4host-manager.org.apache.juli.AsyncFileHandler.level = FINE
4host-manager.org.apache.juli.AsyncFileHandler.directory = ${catalina.base}/logs
4host-manager.org.apache.juli.AsyncFileHandler.prefix = host-manager.

java.util.logging.ConsoleHandler.level = FINE
java.util.logging.ConsoleHandler.formatter = org.apache.juli.OneLineFormatter
```

该文件中还有其他日志级别配置, 如http2, 或是websocket相关的日志等, 只需解开相应的注释即可.

## 4. HTTPS认证

[完美配置Tomcat的HTTPS](http://blog.csdn.net/huaishuming/article/details/8965597)

### 4.1 JDK工具生成证书

**1. 生成key文件**

```
[root@localhost conf]# keytool -genkey -alias tomcat -keyalg RSA -keystore ./tomcat.keystore
Enter keystore password:  
Re-enter new password: 
What is your first and last name?
  [Unknown]:  tomcat.generals.space
What is the name of your organizational unit?
  [Unknown]:  
What is the name of your organization?
  [Unknown]:  
What is the name of your City or Locality?
  [Unknown]:  
What is the name of your State or Province?
  [Unknown]:  
What is the two-letter country code for this unit?
  [Unknown]:  
Is CN=tomcat.generals.space, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown correct?
  [no]:  yes

Enter key password for <mykey>
	(RETURN if same as keystore password):  
Re-enter new password: 
```

**2. 生成证书文件**

```
$ keytool -export -file ./tomcat.crt -alias tomcat -keystore ./tomcat.keystore 
Enter keystore password:  
Certificate stored in file <./tomcat.crt>
```

### 4.2 修改tomcat配置

`server.xml`原配置如下

```xml
    <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
               maxThreads="150" SSLEnabled="true">
        <SSLHostConfig>
            <Certificate certificateKeystoreFile="conf/localhost-rsa.jks"
                         type="RSA" />
        </SSLHostConfig>
    </Connector>

```

```xml
    <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
               maxThreads="150" SSLEnabled="true">
        <SSLHostConfig>
            <Certificate certificateKeystoreFile="conf/tomcat.keystore"
                         certificateKeystorePassword="123456"
                         type="RSA" />
        </SSLHostConfig>
    </Connector>
```

### 4.3 FAQ

#### 4.3.1 

问题描述: 修改tomcat配置以后, 重启tomcat, 日志报错如下

```
java.lang.IllegalArgumentException: java.io.IOException: Alias name tomcat does not identify a key entry
```

原因分析: 在使用`keytool`命令创建`.keystore`文件时未指定`-alias`选项.

解决方法: 指定`-alias`选项重新生成`.keystore`文件, 再重启tomcat即可.