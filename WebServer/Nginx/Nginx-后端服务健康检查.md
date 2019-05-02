# Nginx-后端服务健康检查

参考文章

1. [[技术分享] Nginx实战系列之功能篇----后端节点健康检查](http://www.iyunv.com/thread-38535-1-1.html)

nginx默认通过检测端口状态判断后端upstream节点是否在线的, 服务直接挂掉甚至服务器宕机都可以检测到.

```
upstream backend {
        server 10.1.1.110:8080 max_fails=1 fail_timeout=10s;
        server 10.1.1.122:8080 max_fails=1 fail_timeout=10s;
}
```

`max_fails=指定数值`: 设置Nginx与后端服务器通信的尝试失败的次数。在`fail_timeout`参数定义的时间段内，如果失败的次数达到此值，Nginx就认为该后端节点不可用。在下一个`fail_timeout`时间段，服务器不会再被尝试。 失败的尝试次数默认是1(设为0就会停止统计尝试次数，认为此节点是一直可用的). 可以通过指令`proxy_next_upstream`、`fastcgi_next_upstream`和`memcached_next_upstream`来配置什么是失败的尝试。 默认配置时, `http_404`状态不被认为是失败的尝试。

`fail_timeout=时间`: 设置服务器被认为不可用的时间段以及统计失败尝试次数的时间段。在这段时间中，服务器失败次数达到指定的尝试次数，服务器就被认为不可用。并且下一个时间段内的请求将不再发给出问题的节点. 默认情况下，该超时时间是10秒。

但是很多时候服务本身出了问题如执行缓慢, 磁盘空间满导致无法写入日志时, nginx还是会照样向该节点转发请求.

使用内置的`proxy_next_upstream`命令, 根据后端服务返回状态码确定"失败的尝试". 对于判断已经失败的节点, 可以停止对其的转发.

语法

```
proxy_next_upstream error | timeout | invalid_header | http_500 | http_502 | http_503 | http_504 | http_404 | off ...;
```

使用方法

```
proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
```

...不建议使用404状态码判断, 因为某个页面找不到而导致整个节点用不了还是相当那啥的.