# Nginx搭建代理HTTP服务器

这里要求的代理服务器不是简单的访问`www.abc.com?key=value`由nginx实际取回`www.xyz.com?key=value`这样类似于重定向的功能, 而是那种可以在chrome中的http代理服务器配置中填写nginx所在服务器IP及nginx监听端口, 每次访问网络时由代理服务器代为获取的形式.

```shell
server {
    resolver 8.8.8.8 1.1.1.1;
    resolver_timeout 5s;
    listen       0.0.0.0:80;

    access_log  /var/log/nginx/access_proxy.log  main;
    error_log  /var/log/nginx/error_proxy.log;

    location / {
        proxy_pass $scheme://$host$request_uri;
        proxy_set_header Host $http_host;

        proxy_buffers 256 4k;
        proxy_max_temp_file_size 0;
        proxy_connect_timeout 30;

        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 301 1h;
        proxy_cache_valid any 1m;
    }
}
```

关于`location`块中的`proxy_*`不再多介绍, `proxy_set_header`可以决定是否将客户端IP对目标服务器隐藏, 也许这就是高匿代理的秘密所在. 开头的`resolver`字段是必须的, 因为用户在设置代理服务器之后访问网络不会再自行进行DNS解析, 而是将目标网址直接发送给代理服务器, 此时需要代理服务器自己去解析, 所以只能设置DNS地址.

另外, nginx貌似不能作为`https`代理, 因为nginx不支持CONNECT，所以如果访问Https网站, 比如: `https://www.google.com`, nginx的access.log 日志如下:

```shell
"CONNECT www.google.com:443 HTTP/1.1" 400
```