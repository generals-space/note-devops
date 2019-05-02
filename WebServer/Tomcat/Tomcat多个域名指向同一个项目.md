# Tomcat多个域名指向同一个项目

参考文章

1. [Tomcat多个域名指向同一个项目](http://blog.csdn.net/u013076997/article/details/54316064)

tomcat版本: 7.0.55

有时候我们需要将多个域名指向同一个项目，那么在tomcat服务器下该如何实现呢？

之前查过有人说在 tomcat安装目录`conf/server.xml`文件中配置多个`<Host>`来实现这个功能.

最初的尝试如下, 同一个项目映射了两个不同域名.

```xml
<Host name="hi.mopo.com"  appBase="myapps" unpackWARs="true" autoDeploy="true">
    <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
            prefix="localhost_access_log." suffix=".txt"
            pattern="%h %l %u %t &quot;%r&quot; %s %b" />
    <Context docBase="/usr/mopo-pc/sns-pc-wap/apache-tomcat-7.0.55/myapps/sns-mopo-website" path="" />
</Host>

<Host name="hi.imopo.net"  appBase="myapps" unpackWARs="true" autoDeploy="true">
    <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
            prefix="localhost_access_log." suffix=".txt"
            pattern="%h %l %u %t &quot;%r&quot; %s %b" />
    <Context docBase="/usr/mopo-pc/sns-pc-wap/apache-tomcat-7.0.55/myapps/sns-mopo-website" path="" />
</Host>
```

但是这样的结果是, 只有第一个域名能够正常访问到项目, 第二个域名的配置不生效(反正就是谁在前面谁生效), 而不是像参考文章1中所说, 会同时加载多次应用浪费资源. 

不过真正的解决方法倒是有效的, 就是使用`Alias`标签.

```xml
<Host name="hi.mopo.com"  appBase="myapps" unpackWARs="true" autoDeploy="true">
    <Alias>hi.imopo.net</Alias>
    <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
            prefix="localhost_access_log." suffix=".txt"
            pattern="%h %l %u %t &quot;%r&quot; %s %b" />
    <Context docBase="/usr/mopo-pc/sns-pc-wap/apache-tomcat-7.0.55/myapps/sns-mopo-website" path="" />
</Host>
```

重启生效.