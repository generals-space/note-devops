# Apache端口转发

参考文章

1. [Apache HTTP Server 与 Tomcat 的三种连接方式介绍](https://www.ibm.com/developerworks/cn/opensource/os-lo-apache-tomcat/)

这是利用`Apache`自带的`mod_proxy`模块使用代理技术与后端节点进行通信. 在配置之前请确保是否使用的是2.2+ 版本的Apache. 因为 2.2版本对这个模块进行了重写, 大大的增强了其功能和稳定性.

首先需要加载模块

```
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
```

`http_proxy`模式是基于`HTTP`协议的代理, 一个最简单的配置如下

```
ProxyPass /images !
ProxyPass /css !
ProxyPass /js !
ProxyPass / http://localhost:8080/
```

在这个配置中, 除了`/images`, `/css`, `/js`几个目录外, 我们把所有访问`http://localhost`的请求转发到`http://localhost:8080/`, 这也就是后端服务节点的访问地址. 

负载均衡配置

```xml
ProxyPass /images !
ProxyPass /css ! 
ProxyPass /js !

ProxyPass / balancer://example/
<Proxy balancer://example/>
BalancerMember http://server1:8080/
BalancerMember http://server2:8080/
BalancerMember http://server3:8080/
</Proxy>
```

## FAQ

1. Reason: DNS lookup failure for: xxx...

情境描述: 配置`ProxyPass`时, 访问apache页面出现这个提示. 

解决方法: `ProxyPass`参数的目标url必须以斜线`/`结尾.

参考: [apache httpd 代理: Reason: DNS lookup failure for: 127.0.0.1](http://bbs.csdn.net/topics/380098615)