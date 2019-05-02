# nginx与php-fpm分离实验

## 1 场景分析

非生产环境下, nginx, php-fpm及php工程代码都是放在同一台主机上. 其工作方式一般为: nginx接收客户端请求, 如果是静态文件, 则由其本身直接返回给客户端; 如果是php脚本文件, 则将其通过`fastcgi_*`系列指令交由`php-fpm`(而且一般是9000端口)进程处理, 然后将其处理的结果返回. 这种形式最容易实现.

现在有如下场景: 有A, B, C, D共4台主机, X, Y两个php工程. 其中A, B共同作为前端nginx转发(可以认为前面由F5或另一台Nginx将请求转发至A和B), 根据 `location`前缀判断客户端访问的是X还是Y工程, 如`/X/index.php`即转向C或D的X目录并通过`proxy_*`系列命令与C和D进行数据传输; C与D上各自部署X, Y两个工程, 并按照上面的方式运行了nginx + php-fpm; 另外,X的数据库在C机器上, Y的数据库在D机器上. 总体架构如下图.

可以看到, C和D上面运行的程序过多, 而且相互依赖, 耦合严重, 并且nginx配置修改时很可能要涉及A, B, C, D四台机器, 配置烦琐, 尤其业务较重时横向扩展相当复杂. 现在考虑, 将运行单元分离, nginx, php工程与数据库分别放在单独的服务器上, 各司其职. 基本架构如下.

------

## 2 工程路径

目前一个问题是, **php工程代码应该放在哪里?**

有两种可能的猜测: 1. 工程目录放在php-fpm主机中, nginx 接收前端请求, 将`root`指令设置为工程目录在fpm主机上的路径, 而本身不保留工程代码; 2. 工程目录放置在nginx主机中, nginx接收前端请求, 在本地寻找`root`指令所指相应的本地目录中的php脚本, 将其作为数据流传到php-fpm主机相应端口, 由php-fpm解析并执行. 仔细想一下, 其实第2种情况的可能性不大, 毕竟即使nginx与php-fpm主机同属内网环境, 传输php脚本数据流的代价还是太大了.

实际测试一下. 测试环境为:

docker CentOS7镜像下源码安装php与nginx, 和官方mysql镜像(如果依赖于`systemctl`的还是暂时放弃吧, CentOS目前开启`systemctl`相当麻烦, 要等到7.2时才能修复).

nginx 配置大体如下:

```shell

http {
...
  log_format main '$remote_addr - $remote_user "$request" '
  '$status $body_bytes_sent '
  '"$http_user_agent" "$http_x_forwarded_for" $document_root $fastcgi_script_name';

  access_log logs/access.log main;
..
  server {
    listen 80;
    server_name localhost;
    location / {
      root /var/www/html;
      fastcgi_pass php-fpm主机IP:9000;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include fastcgi_params;
    }
  }
}
```

注意`server`块下的`root`字段值, 在php-fpm所在主机的`/var/www/html`目录下建立一个php文件, 这里命名为`here.php`.

```php
<?php
  echo "i am here";
?>
```

使用curl命令(容器中一般不带有这个命令, 需要自行安装)访问nginx所在主机IP`curl NginxIP/hehe.php`, 可以得到`i am here`的输出. 说明nginx传给`php-fpm`进程的, 不是php文件流, 而是脚本所在路径, `php-fpm`进程会根据这个路径自行寻找并解析.

------

## 3 动静分离

然而这个问题解决不意味着一切都结束了, 在这种情况下, **nginx的动静分离怎么实现?**

先问问php-fpm是怎么看的...在php-fpm所在主机(容器)的`/var/www/html`目录下放一张图片`img.jpg`, 然后访问`curl NginxIP/img.jpg`. 命令行下得到

```shell
Access denied
```

查看nginx的错误日志, 有如下输出

```
2016/07/03 08:56:47 [error] 36#0: *1 FastCGI sent in stderr: "Access to the script '/var/www/html/img.jpg' has been denied (see security.limit_extensions)" while reading response header from upstream, client: 127.0.0.1, server: localhost, request: "GET /img.jpg HTTP/1.1", upstream: "fastcgi://172.17.0.2:9000", host: "localhost"
```

...so, php-fpm是没法自己处理静态文件的, 还是要由nginx自己来. 那么问题来了, nginx与php-fpm所在主机都要保留一份工程代码, 而且路径还必需相同以便于同时正常响应静态文件请求与动态请求...那么这种nginx与php-fpm的分离还有必要吗?

另外, 就算nginx按照这样的方式实现了动态分离, 如果用户有 **上传文件** 的需要, 怎么办? 上传的文件是在nginx这边还是php-fpm那里? 猜测是php-fpm那里, 因为上传文件流是需要由php代码捕获并存储的.

以`wordpress`为例, 在nginx与php-fpm所在主机的`/var/www/html`部署wordpress工程, nginx自行处理静态文件请求. nginx大致配置如下

```shell
server {
  listen 80;
  server_name localhost;
  root /var/www/html;
  index index.php;
  location / {
    try_files $uri $uri/ /index.php?$args;
  }
  location ~ \.php$ {
    fastcgi_pass php-fpm主机IP:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param QUERY_STRING $query_string;
    include fastcgi_params;
  }
  location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
    expires 30d;
  }
}
```

安装配置成功, 然后在wordpress管理后台写一篇文章, 并在文章中插入一张图片并发布. 其实不用等到发布了, 上传图片时后台会提示uploads目录权限不足, 于是在php-fpm所在主机的wordpress/wp-content目录下建立uploads目录并设置其权限为777, 然后上传成功...但是没有办法看到, 图片预览失败. 文章发布后, 图片依然是破碎的状态.

在php-fpm主机的`wordpress/wp-content/uploads/2016/07`目录下可以找到上传的图片, 然而nginx所在主机的相应目录下并没有这个图片, 这就是看不到上传的图片的原因-静态文件请求不会到达后端的程序服务器.

这种情况下, 解决办法可以是使用`rsync`进行数据同步, 包括更新的代码文件, 用户上传的静态文件等.

但还是那个问题, 这样做nginx与php-fpm的分离到底是不是显得有点得不偿失了?

------

## 4 扩展

以下这些情况下, 进行业务分离会比较方便.

- 后台程序(不只是php)比如`django`,`dotcms`等, 会将静态文件路径隐藏, 所有静态请求都需要由程序本身去寻找并响应;

- 完全没有用户上传行为的需要;

- php工程目录其实是以nfs形式挂载在共享网络卷上;

如果是在小型业务下, 额外搭建同步服务器还是很费时间的.
