# 访问出现500 - error.log中报错rewrite or internal redirection cycle while internally redirecting to index.html

参考文章

1. [一次nginx代理前端报rewrite or internal redirection cycle while internally redirecting to “/index.html“ 记录](https://blog.csdn.net/p243679396/article/details/113573080)

的确如参考文章1所说, 静态页面的路径没配对, 工程放在`/root`下, 但配置文件里配的是`/home`...

```
2022/03/14 20:44:26 [notice] 49162#49162: signal process started
2022/03/14 20:45:30 [error] 49169#49169: *6 rewrite or internal redirection cycle while internally redirecting to "/index.html", client: 192.168.233.1, server: admin-b2b2c.pickmall.cn, request: "GET / HTTP/1.1", host: "admin-b2b2c.pickmall.cn"
2022/03/14 20:45:30 [error] 49167#49167: *7 rewrite or internal redirection cycle while internally redirecting to "/index.html", client: 192.168.233.1, server: admin-b2b2c.pickmall.cn, request: "GET /favicon.ico HTTP/1.1", host: "admin-b2b2c.pickmall.cn", referrer: "http://admin-b2b2c.pickmall.cn/"
```
