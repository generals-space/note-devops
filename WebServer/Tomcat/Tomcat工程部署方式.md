# Tomcat工程部署方式

参考文章

[Tomcat服务器下部署项目几种方式](http://zhourrr1234-126-com.iteye.com/blog/1878790)

## 1. 直接将web项目文件(.war文件)拷贝到webapps目录下

Tomcat的Webapps目录是Tomcat默认的应用目录. 当服务器启动时, 会加载所有这个目录下的应用.

所以可以将Java项目打包成一个 war包放在目录下, 服务器会自动解开这个war包, 并在这个目录下生成一个同名目录.

一个war包就是有特定格式的压缩包, 它是将一个JavaWeb程序的所有内容进行压缩得到.

具体如何打包, 可以使用许多开发工具的IDE环境. 如Eclipse等. 也可以用 cmd 命令: `jar -cvf mywar.war myweb`

webapps这个默认的应用目录也是可以改变的。打开Tomcat的conf目录下的server.xml文件，找到下面内容：

```xml
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true" xmlValidation="false" xmlNamespaceAware="false">
```

将`appBase`的值修改为指定目录即可, 可以看到`appBase`是以tomcat根目录为相对路径的.

## 2. 在server.xml中指定

在Tomcat的配置文件中, 一个Web应用就是一个特定的Context, 可以通过在server.xml中添加Context字段以部署一个Java应用程序.

在Tomcat中的conf目录中, 在server.xml中的host节点中添加:

```xml
<Context path="/solo" docBase="/var/www/html/solo" debug="0" privileged="true">
</Context>
```

或

```xml
<Context path="/solo" reloadable="true" docBase="/var/www/html/solo" workDir="/var/www/html/work"/>
```

说明：

- path: url访问路径, 当path="/solo"时, 访问地址应为http://localhost:8080/solo;

- docBase: 是应用程序的物理路径, 可以是相对路径, 以`Host`字段中的appBase属性为基准;

- workDir: 是这个应用的工作目录，存放**运行时刻**生成的与这个应用相关的文件, tomcat/work目录貌似就是干这个的;

- debug: 设定debug level, 0表示提供最少的信息，9表示提供最多的信息;

- privileged: 设置为true的时候，才允许Tomcat的Web应用使用容器内的Servlet;

- reloadable: 如果为true，则tomcat会自动检测应用程序的`/WEB-INF/lib` 和`/WEB-INF/classes`目录的变化, 自动装载新的应用程序, 可以在不重启tomcat的情况下改变应用程, 实现热部署;


## 3. 创建一个Context文件

在`conf`目录中, 新建 `Catalina/localhost`目录(Tomcat第一次启动时应该会将自动创建), 在该目录中新建一个xml文件, 名字不可以随意取, 要和path后的值一致. 按照下边这个path的配置. xml的名字应该就是solo(`solo.xml`), 该xml文件的内容为:

```xml
<Context path="/solo" docBase="/var/www/html/solo" debug="0" privileged="true"></Context>
```

tomcat自带例子`host-manager`如下：

```xml
<Context docBase="${catalina.home}/server/webapps/host-manager" privileged="true" antiResourceLocking="false" antiJARLocking="false">
</Context>
```

这个例子是tomcat自带的, 编辑的内容实际上和第二种方式是一样的, **这个xml文件名字就是访问路径**, 与应用目录的真实名称无关.

注意:

1. 删除一个Web应用同时也要删除webapps下相应的文件夹和server.xml中相应的Context, 还要将Tomcat的`conf\catalina\localhost`目录下相应的xml文件删除, 否则Tomcat仍会去配置并加载.

2. web项目的`META_INF`目录下可以有`context.xml`文件, 包含`Context`字段. 目的是配置项目本身所需的数据源, 会话管理等机制. Tomcat在启动时会加载这个配置文件. 这样看来, Tomcat所包含的Context字段(不管是server.xml还是conf/Catalina/localhost/项目名.xml)都是为了项目路径的设置, 与项目本身所需环境没有直接联系.

其他部署方式及详细参数设置可参考Tomcat官方文档:

http://tomcat.apache.org/tomcat-8.0-doc/deployer-howto.html