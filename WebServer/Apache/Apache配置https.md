# Apache配置https

参考文章

1. [apache https配置](http://www.cnblogs.com/best-jobs/p/3298258.html)

apache开启https需要加载ssl模块, 查看apahce的modules目录中是否有`mod_ssl.so`, 并在配置文件中写入如下行

```
LoadModule ssl_module modules/mod_ssl.so
```

确认mod_ssl模块被启用, 然后配置`ssl.conf`文件如下.

```xml
LoadModule ssl_module modules/mod_ssl.so
Listen 443 https

<VirtualHost *:443>
DocumentRoot 网站工程目录, 同nginx中root字段
ServerName 域名, 同nginx中的server_name
...
SSLEngine on
SSLProtocol all -SSLv2
SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW

SSLCertificateFile crt文件路径
SSLCertificateKeyFile key文件路径
...
</VirtualHost>
```

确认`ssl.conf`已被引入到主配置文件.