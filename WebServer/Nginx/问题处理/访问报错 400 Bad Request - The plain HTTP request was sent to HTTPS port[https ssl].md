# 访问报错 400 Bad Request - The plain HTTP request was sent to HTTPS port[https ssl]

参考文章

1. [Nginx如何解决“The plain HTTP request was sent to HTTPS port”错误](https://www.centos.bz/2018/01/nginx%E5%A6%82%E4%BD%95%E8%A7%A3%E5%86%B3the-plain-http-request-was-sent-to-https-port%E9%94%99%E8%AF%AF/)

情景描述

使用阿里云提供的ssl证书配置nginx的https接口, 同时保留了80的普通http接口. 配置类似如下

```conf
server{
    listen 80;
    listen 443 ssl;
    ssl on;
    ## xxx
}
```

当用户访问`https://`时, 一切正常.

但访问`http://`时, 页面就会报上述错误.

参考文章1中的分析一针见血: 客户试图通过HTTP访问你的网站, 但Nginx总是使用SSL交互, 但原来的请求（通过端口80接收）是普通的HTTP请求, 于是会产生错误.

解决办法

要么把上述的`ssl on;`改成`ssl off;`, 要么把http与https的server块分开处理.