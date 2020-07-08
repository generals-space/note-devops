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
