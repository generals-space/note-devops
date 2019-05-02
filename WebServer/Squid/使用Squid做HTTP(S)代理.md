# 使用Squid做HTTP(S)代理

参考文章

1. [用squid做http/https正向代理](https://www.cnblogs.com/echo1937/p/6728461.html)

## 1. 引言

1. 为什么不使用nginx？

> nginx最多只能实现http正向代理, 无法实现https的正向代理, 因为nginx不支持`connect`类型的请求, 无法与目标https网站建立连接.

2. squid client的DNS查询是由谁完成的？

> 根据实验结果，DNS查询也是由squid server完成的(与nginx的http代理模式相同). 因此server需要配置DNS解析服务器；或者在squid.conf中配置dns_nameservers指定dns地址。

## 2. 步骤

1. 安装`yum install -y squid`

2. 打开内核转发`net.ipv4.ip_forward = 1`

3. 编辑`/etc/squid/squid.conf`, 把`http_access deny all`改成`http_access allow all`.

4. 启动squid服务即可.