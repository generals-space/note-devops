# Nginx-stream模块四层转发[tcp]

参考文章

1. [Nginx——stream模块](https://www.cnblogs.com/zh-dream/p/12911609.html)

`stream`与`http`平级, 其下也拥有`server`, `upstream`等子块.

我用到的一个工具`adb`只支持监听`127.0.0.1`的接口(其实也不是, 只是比较麻烦), 所以通过 nginx 做一个转发.

```conf
stream {
    upstream adbserver {
        hash $remote_addr consistent;
        # $binary_remote_addr;
        server 127.0.0.1:5037 weight=5 max_fails=3 fail_timeout=300s;
    }

    server {
        ## 数据库服务器监听端口
        listen 172.17.0.6:5037;
        proxy_connect_timeout 120s;
        proxy_buffer_size 256k;
        proxy_pass adbserver;
    }
}
```

> 172.17.0.6 为内网网卡地址.

`stream`模块没有`location`块.
