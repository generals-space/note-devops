# nginx -t 语法检测报错[emerg] invalid host in upstream


## 问题描述

配置完`upstream`块, 启动或是检查时报错如下

```
$ nginx -t
nginx: [emerg] invalid host in upstream "172.16.3.132:8080/" in /usr/local/nginx/conf/nginx.conf:79
nginx: configuration file /usr/local/nginx/conf/nginx.conf test failed
```

## 原因分析

注意: upstream的标准写法是

```
upstream pool名称 {
  server IP:端口 参数;
}
```

其中`IP`前不可以加`http(s)://`前缀, 端口后不可以加`/`和任何后缀.
