# FastDFS问题处理

## 1. Java客户端上传文件连接tracker超时

Java工程在IDC, 192网段, FastDFS部署在云服务器, 通过公网IP连接.

排除双方防火墙, SELinux等的影响, 确认`tracker`与`storage`的`bind_addr`为空(即允许所有连接), 而且在Java工程所在服务器上telnet目标FastDFS的traker端口是能通的, 但是上传时就是显示超时...

按照[参考文章](http://blog.csdn.net/tjcyjd/article/details/50808740)的提示, 发现在FastDFS的storage配置文件中, tracker的地址写的是内网IP.

```
# tracker_server can ocur more than once, and tracker_server format is
#  "host:port", host can be hostname or ip address
## tracker_server=10.19.55.36:22122             ## 内网IP, 错误
tracker_server=106.75.5.133:22122               ## 公网IP, 正确
```

客户端直接连接的是tracker, 但是仍然需要把storage的`tracker_server`地址改成公网的.