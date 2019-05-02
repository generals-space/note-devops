# Apache配置虚拟主机

参考文章

1. [Apache 配置虚拟主机三种方式](http://www.cnblogs.com/hi-bazinga/archive/2012/04/23/2466605.html)

2. [Apache配置多个监听端口和不同的网站目录的简单方法](https://blog.csdn.net/robertsong2004/article/details/46830799)

nginx可以通过`IP:端口`, `域名`来适配不同的规则, apache当然也可以.

## 1. 多域名

apache默认监听80端口, 当多个域名都同时指向这个服务器时, 如何配置?

在不修改`conf/httpd.ini`的情况下, 在`conf.d`目录添加`vhosts.conf`文件, 内容如下

```
<VirtualHost *:80>
    ServerName www.generals.com
    ## 这里注意必须是目标工程的顶层目录, 这里随便建了个新目录
    DocumentRoot /var/www/html2
    <Directory "/var/www/html2">
        Options Indexes FollowSymLinks
        AllowOverride All
        ## 2.4中不能再使用`Allow from all`
        Require all granted
    </Directory>
</VirtualHost>
```

编辑完成后重启apache, 访问`www.generals.com`即可看到效果. 多个`VirtualHost`块也是可以的.

## 1. 多端口

与上面相同, 都要在`vhosts.conf`文件中添加虚拟主机配置, 但是一定要额外加上一个`Listen`标签. 单纯的`VirtualHost`块指定的端口不能让apache开启监听, 所以要先用`Listen`标签单独监听.

```
## 注意这个!!!
Listen 8080
<VirtualHost *:8080>
    ServerName www.generals.com
    ## 这里注意必须是目标工程的顶层目录, 这里随便建了个新目录
    DocumentRoot /var/www/html2
    <Directory "/var/www/html2">
        Options Indexes FollowSymLinks
        AllowOverride All
        ## 2.4中不能再使用`Allow from all`
        Require all granted
    </Directory>
</VirtualHost>
```
