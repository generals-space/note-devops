# Squid-访问限制

参考文章

1. [CentOS 7 安装配置带用户认证的squid代理服务器](https://www.cnblogs.com/fjping0606/p/6595790.html)

2. [搭建需要身份认证的 Squid 代理](https://maoxian.de/2016/06/1415.html)

squid需要使用`htpasswd`命令生成密码文件, 这个命令在`httpd-tools`包里.

```
yum install httpd-tools
```

创建密码文件, 并添加用户

```
$ cd /etc/squid/
$ htpasswd -c squid_passwd general
New password: 
Re-type new password: 
Adding password for user general
$ ls
cachemgr.conf  cachemgr.conf.default  errorpage.css  errorpage.css.default  mime.conf  mime.conf.default  squid.conf  squid.conf.default  squid_passwd
```

`htpasswd`的`-c`选项是用来创建密码文件`squid_passwd`的, 继续添加用户时就不必再指定这个选项了. 

```
$ htpasswd squid_passwd test
New password: 
Re-type new password: 
Adding password for user test
```

接下来修改`/etc/squid/squid.conf`文件, 在`http_access deny all`之前加上下面几句: 

```
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/squid_passwd
auth_param basic children 5
auth_param basic realm Squid proxy-caching web server
auth_param basic credentialsttl 2 hours
auth_param basic casesensitive off
acl ncsa_users proxy_auth REQUIRED
http_access allow ncsa_users
```

下面说说这几个选项的含义: 

`auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/squid_passwd`: 指定密码文件和用来验证密码的程序

`auth_param basic children 5`: 鉴权进程的数量

`auth_param basic realm Squid proxy-caching web server`: 用户输入用户名密码时看到的提示信息

`auth_param basic credentialsttl 2 hours`: 用户名和密码的缓存时间，也就是说同一个用户名多久会调用`ncsa_auth`一次

`auth_param basic casesensitive off`: 用户名是否需要匹配大小写

`acl ncsa_users proxy_auth REQUIRED`: 所有成功鉴权的用户都归于`ncsa_users`组

`http_access allow ncsa_users`: 允许 ncsa_users 组的用户使用Proxy