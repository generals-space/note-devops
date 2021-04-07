# SSH隧道,端口转发与内网穿透.3.autossh

参考文章

1. [SSH隧道技术简介](http://blog.sina.com.cn/s/blog_6ca2bddf0100rljn.html)
2. [SSH的三种端口转发](https://jeremyxu2010.github.io/2018/12/ssh%E7%9A%84%E4%B8%89%E7%A7%8D%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91/)
3. [windows10自带ssh实现远程内网主机](https://blog.csdn.net/zhj082/article/details/80795998)
    - win10自带的ssh客户端的使用方法与linux的相同

在使用自建VPS玩翻墙时, 经常看到`autossh`这个工具. 其典型的使用方法如下

在本地linux虚拟机上执行

```
autossh -M 5678 -D 1080 -qTfNn 用户名@vps地址
```

然后使用xshell等工具建立与本地linux虚拟机的ssh连接, 同时创建一个动态转发端口, 端口号指定为1080. 在ssh会话连接期间, 就可以通过chrome指定代理端口为本地的1080去快乐地翻墙了.

其实`autossh`只是一个监视ssh会话的小工具, 它自己只有3个参数: `-M`, `-f`, `-V`. 其他的参数都是要传递给ssh命令的的. 上面的命令也是上一篇文章`2.3`中介绍的socks代理的动态端口的应用.

`-M`指定了一个克隆端口, 它通过这个端口来检测当前ssh连接的状态, 一但有问题就会尝试重连.

`-f`选项不会传递给ssh, 而是会被autossh捕获. 不过作用其实和ssh的一样, 也是作为后台进程运行的. 有一点区别是, 在使用了`-f`选项后, 此次ssh连接就没有办法接收密码的, 所以只能用key的方式连接.
