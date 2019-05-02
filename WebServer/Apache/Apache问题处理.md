# Apache问题处理

## 1. You don't have permission to access /index.php on this server.

参考文章

1. [apache2.4配置虚拟主机遇到的那些坑](https://blog.csdn.net/hjc1984117/article/details/53114248)

LAMP环境搭建好后访问网站, 网页上输出了上述错误, 网上说法不一, 我曾经尝试过更改对应`php-fpm`的用户与apache相同(`www` -> `apache`), 也尝试过更改源码目录的权限, 修改过apache的启动用户...都不行.

参考文章1中也遇到了这种情况, 他给出的答案有效. 修改配置文件中的访问权限要根据apache的版本不同而变化, 2.2和2.4的权限配置写法是不一样的.

在apache2.2中, 在`<Directory "xxx"></Directory>`标签修改为如下:

```
<Directory "代码目录">
    Options Indexes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
</Directory>
```

在apache2.4中, 则要改成这样:

```
<Directory "代码目录">
    Options Indexes FollowSymlinks
    AllowOverride All
    Require all granted
</Directory>
```