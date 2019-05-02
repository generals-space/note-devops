# Tomcat应用场景及相应配置

## 1. Tomcat配置文件理解

tomcat/conf/server.xml默认配置为如下结构

```xml
server{
    service{
        connector
        engine{
            host
        }
    }
}
```

另外还有tomcat/conf/context.xml. 从层次上来说, context字段为host的子字段. 即

```xml
host{
    context
}
```

- server可以看作对应于nginx命令本身, 它是tomcat实例配置, 负责tomcat进程的启动与关闭;

- service可以看作nginx.conf中的`server`, 可以设置监听端口与工程执行程序;

- connector可以看作nginx.conf中`server`块下的`listen`字段, 主要起监听端口的作用;

- engine有点像nginx.conf中`server`块下的`location`中的`fastcgi_proxy`与`proxy_proxy`. 不过nginx本身无法执行程序, tomcat则不需要, 它本身有但也只有javaWeb的执行引擎, 所以几乎不需要再进行配置;

- host则可以看作nginx.conf中`http`块下的`root`字段, 注意不是`server`中的`root`, 因为host只指定网站工程目录的路径, 不需要像nginx那样为每个`location`单独写路由;

- context就有点像nginx.conf中`server`块下的`root`字段了. 可以看作javaWeb工程实例配置, 指定工程目录的存放路径与访问路径, 工程目录存放路径可以以`host`字段为基准做相对路径, 也可以脱离host指定的根路径另外指定绝对路径;

## 1. Tomcat监听多个端口

[参考文档](http://linder.iteye.com/blog/782071)

Tomcat默认只监听8080端口, 如果要同时监听多个端口, 需要在tomcat/conf/server.xml中创建多个`service`块并设置不同的端口(位于`connector`字段). 结构如下.

```xml
server{
    service{
        connector
        engine{
            host
        }
    }
    service{
        connector
        engine{
            host
        }
    }
}
```

经过实验, 两个`service`字段与它们其中的`engine`字段的`name`属性可以相同, 不会影响tomcat启动的正确性, 暂时不清楚名称对tomcat运行的影响.

不过话说本来tomcat的性能就不高, 同一个tomcat监听多个端口还可能会进一步降低性能. 不如配置多个tomcat实例来的实在.

> 注意:

> 一个server.xml文件内只能放置一个`server`块, 多了会出错.