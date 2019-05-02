# Nginx-多个https证书

参考文章

1. [【nginx】配置nginx支持ssl sni （一个IP绑定多个证书）](http://blog.csdn.net/cccallen/article/details/6672451)

2. [通过开启Nginx TLS SNI来支持同一IP下多SSL证书](http://www.2cto.com/article/201503/386296.html)

在不支持TLS SNI的nginx中, 相同端口下(如443), 如果有多个不同的https server块(`server_name`字段不同), 用户访问时, 只会使用配置文件中第一个server块中指定的证书(或是`server_name`指定了`default`标识的server块, 实际上这与nginx的访问规则有关). 这样的话, 配置文件中靠后的证书就无法生效.

## 如何查看是否支持SNI???

```
$ nginx -V
nginx version: nginx/1.6.0
built by gcc 4.1.2 20080704 (Red Hat 4.1.2-46)
TLS SNI support disabled
...
```

## 如何启用SNI???

实际上, TLS SNI是openssl的特性, nginx的SNI选项未开启大多是由于当前系统中的openssl过于老旧, 所以你需要手动编译较新的openssl.

下载openssl源码, 解压, 不需要编译, 因为openssl的升级可能会影响整个系统.

```
$ wget http://www.openssl.org/source/openssl-1.0.0d.tar.gz
$ tar xvf openssl-1.0.0d.tar.gz
```

编译nginx, 添加`--with-openssl=openssl解压后的路径`这个编译选项就好了. 当然, ` --with-http_ssl_module`选项应该是本来就有的.

关于nginx平滑升级不在文章讨论范围, 所以直接make就好. 到时重启一下就好了.