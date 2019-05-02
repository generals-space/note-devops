# HAProxy应用场景-HTTPS

参考文章

[haproxy ssl 配置方式](http://www.tuicool.com/articles/iAjMra)

## 1. 基本配置-haproxy加载证书

haproxy的编译/安装方法

```
$ make PREFIX=/usr/local/haproxy TARGET=linux26 USE_PCRE=1 USE_OPENSSL=1 ADDLIB=-lz
$ make install PREFIX=/usr/local/haproxy
```

```
global
...
    ## tune.ssl.default-dh-param 2048因为我们的SSL密钥使用的是2048bit加密，所以在此进行声明。
    tune.ssl.default-dh-param 2048
...
frontend website
    bind *:443 ssl crt /usr/local/haproxy/etc/servername.pem
    mode http
    log global
    option forwardfor
    reqadd X-Forwarded-Proto:\ https
    default_backend website_pool
backend website_pool
    mode http
    balance roundrobin
    option httplog
    log global
    server website1 127.0.0.1:8080 cookie 1 check inter 1500 rise 3 fall 3 weight 1
    server website1 127.0.0.1:8081 cookie 1 check inter 1500 rise 3 fall 3 weight 1
```

其中`pem`文件是`crt`文件与`key`文件合并得到的. 合并方法为

```
$ cat servername.crt servername.key |tee servername.pem
```

关于`tune.ssl.default-dh-param 2048`, 我并不知道我的密钥是多少位加密, 只是如果不加这一句, haproxy启动时会报如下WARNING, 还是加上吧. 另外, 这一句只能加到`global`块中, 加在`defaults`块中会报错的.

```
[WARNING] 044/120924 (7281) : Setting tune.ssl.default-dh-param to 1024 by default, if your workload permits it you should set it to at least 2048. Please set a value >= 1024 to make this warning disappear.
```

## 2. http强制跳转

访问`http://www.test.com`时, 强制跳转到`http://www.test.com`

```
global
...
    ## tune.ssl.default-dh-param 2048因为我们的SSL密钥使用的是2048bit加密，所以在此进行声明。
    tune.ssl.default-dh-param 2048
...
listen website-http
    bind *:80
    mode http
    log global
    option httplog
    acl http2s hdr(host) www.test.com
    redirect code 301 prefix https://www.test.com if http2s
frontend website
    bind *:443 ssl crt /usr/local/haproxy/etc/servername.pem
    mode http
    log global
    option forwardfor
    reqadd X-Forwarded-Proto:\ https
    default_backend website_pool
backend website_pool
    mode http
    balance roundrobin
    option httplog
    log global
    server website1 127.0.0.1:8080 cookie 1 check inter 1500 rise 3 fall 3 weight 1
    server website1 127.0.0.1:8081 cookie 1 check inter 1500 rise 3 fall 3 weight 1
```