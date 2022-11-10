# Nginx-yum安装指定版本的nginx

参考文章

1. [nginx通过yum安装指定版本](https://www.cnblogs.com/TheoryDance/p/16452007.html)

```ini
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
```

```
yum install nginx-1.12.0
```
