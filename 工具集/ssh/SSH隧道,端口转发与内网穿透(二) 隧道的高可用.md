# SSH隧道,端口转发与内网穿透(二) 隧道的高可用

参考文章

1. [SSH隧道技术简介](http://blog.sina.com.cn/s/blog_6ca2bddf0100rljn.html)
2. [SSH的三种端口转发](https://jeremyxu2010.github.io/2018/12/ssh%E7%9A%84%E4%B8%89%E7%A7%8D%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91/)
3. [windows10自带ssh实现远程内网主机](https://blog.csdn.net/zhj082/article/details/80795998)
    - win10自带的ssh客户端的使用方法与linux的相同

## 1. 自动重连

隧道可能因为某些原因断开, 例如：机器重启, 长时间没有数据通信而被路由器切断等等. 

因此我们可以用程序控制隧道的重新连接, 例如一个简单的循环或者使用djb’s daemontools. 不管用哪种方法, 重连时都应避免因输入密码而卡死程序. 

其实自动重连功能可以通过`autossh`工具完成, 下面会单独介绍.

## 2. 保持长时间连接

有些路由器会把长时间没有通信的连接断开. SSH客户端的`TCPKeepAlive`选项可以避免这个问题的发生, 默认情况下它是被开启的. 如果它被关闭了, 可以在ssh的命令上加上`-o TCPKeepAlive=yes`来开启. 如下

```
ssh -N -f -L 8080:目标服务器IP:80 -o TCPKeepAlive=yes root@中转服务器IP
ssh -N -f -R 2222:127.0.0.1:22 -o TCPKeepAlive=yes root@中转服务器IP
ssh -N -f -D 1080 -o TCPKeepAlive=yes root@中转服务器IP
```

另一种方法是, 去掉`-N`参数, 加入一个定期能产生输出的命令. 例如: `top`或者`vmstat`. 下面给出一个这种方法的例子：

```
ssh -R 2222:127.0.0.1:22 root@中转服务器IP "vmstat 30"
```

## 3. 检查隧道状态

有些时候隧道会因为一些原因通信不畅而卡死, 例如：由于传输数据量太大, 被路由器带入stalled状态. 

这种时候, 往往SSH客户端并不退出, 而是卡死在那里. 

一种应对方法是, 使用SSH客户端的`ServerAliveInterval`和`ServerAliveCountMax`选项.  

`ServerAliveInterval`会在隧道无通信后的一段设置好的时间后发送一个请求给服务器要求服务器响应. 如果服务器在 `ServerAliveCountMax`次请求后都没能响应, 那么SSH客户端就自动断开连接并退出, 将控制权交给你的监控程序. 

这两个选项的设置方法分别是在ssh时加入`-o ServerAliveInterval=m`和`-o ServerAliveCountMax=n`. 其中m, n可以自行定义. 
