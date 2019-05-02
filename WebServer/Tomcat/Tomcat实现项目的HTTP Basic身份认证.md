# Tomcat实现项目的HTTP Basic身份认证

参考文章

1. [tomcat普通登录认证](http://blog.csdn.net/xbtx123/article/details/50716382)

2. [tomcat 设置项目 密码登陆](http://blog.51cto.com/53cto/1754424)

3. [【Http认证方式】——Basic认证](http://blog.csdn.net/u013177446/article/details/54135520)

修改`$TOMCAT/conf/server.xml`

```xml
<tomcat-users>
<!--
  <role rolename="tomcat"/>
  <role rolename="role1"/>
  <user username="tomcat" password="<must-be-changed>" roles="tomcat"/>
  <user username="both" password="<must-be-changed>" roles="tomcat,role1"/>
  <user username="role1" password="<must-be-changed>" roles="role1"/>
-->
    <role rolename="gamecms"/>
    <user username="gameadmin" password="X4yw7Cdg1" roles="gamecms"/>
</tomcat-users>

```

然后还需要在工程配置里添加拦截器配置, 编辑工程目录的`web.xml`, 在`<web-app>`节点下加入如下配置.

```
<web-app>
    <!--添加如下行-->
    <security-constraint>
        <web-resource-collection>
            <web-resource-name>force login</web-resource-name>
            <!-- Define the context-relative URL(s) to be protected -->
            <url-pattern>/*</url-pattern>
            <!-- If you list http methods, only those methods are protected -->
        </web-resource-collection>
        <auth-constraint>
            <!-- Anyone with one of the listed roles may access this area -->
            <role-name>gamecms</role-name>
        </auth-constraint>
    </security-constraint>

    <login-config>   
        <auth-method>BASIC</auth-method> 
        <realm-name>force login</realm-name>
    </login-config>

    <!-- Security roles referenced by this web application -->
    <security-role>
        <role-name>gamecms</role-name>
    </security-role>  
</web-app>
```

重启Tomcat, 访问工程时浏览器会有如下提示

![](https://gitee.com/generals-space/gitimg/raw/master/be0d8af59f812bcd18f1155a56bec3d1.png)
