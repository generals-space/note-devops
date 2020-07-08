# Tomcat日志配置

参考文章

1. [Tomcat访问日志浅析](http://blog.csdn.net/yaerfeng/article/details/40340981)
2. [Tomcat日志设定](http://blog.csdn.net/lk_cool/article/details/4561306/)
3. [tomcat官方文档](http://tomcat.apache.org/tomcat-6.0-doc/config/valve.html#Access_Log_Valve)

tomcat日志信息分为两类:

- 访问日志，记录访问的时间, IP, url等相关信息. 
- 运行时日志，主要记录运行的一些信息，尤其是一些异常错误日志信息. 

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

关于日志变量与其含义, 可见参考文章3.

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

另外还可以将cookie, 客户端请求中带的HTTP头(incoming header), 会话(session)或是ServletRequest中的数据都写到Tomcat的访问日志中，可以用下面的语法来引用. 

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
