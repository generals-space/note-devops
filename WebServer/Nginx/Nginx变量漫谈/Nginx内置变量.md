# Nginx内置变量

## 1. 使用示例

首先看有疑惑的部分, 大多属于url访问的路径信息, 因为可能涉及到nginx内部通过`rewrite`或`try_files`对url的重写, 最终结果与最初访问会有不同.

以如下请求为例(level1, 2是`wordpress`中的分类目录, 9是文章id, `.html`后缀是添加的伪静态, 嗯...不要在意这些细节.

```
http://localhost/level1/level2/9.html?ab=123
```

```
$args	                  ab=123
$query_string	          ab=123
$uri	                  /index.php
$request_uri	          /level1/level2/9.html?ab=123
$request_filename	      /var/www/html/index.php
$fastcgi_script_name	  /index.php
$document_uri	          /index.php
```

### 1.1 `$args`与`$query_string`

这两个最简单了, 都是url后接的参数, 不过好像并没有什么区别, 这个等以后再发现吧;

### 1.2 `$request_uri`与`$uri`

前者是出现在地址栏的uri(去除了url中的协议与主机名), 最为原始和完整, 后者则是前者经过Nginx配置中`rewrite`的`last/break`参数或`try_files`等指令重写/转发等处理之后的值, 且不含请求参数. 本例中对此相关的配置为:

```
try_files $uri $uri/ /index.php?$args;
```

这是wp中伪静态的相关设置, Nginx先尝试在`root`指令指定的根目录按照原始`$uri`寻找, 当然, 它找不到的;

而原始uri看起来又不像是个目录, 而且`$uri/`的确不存在, 继续找;

最后Nginx只能找`/index.php`文件(斜线`/`开头, 是指网站根目录), 并在后面把参数`$args`添加上. 然后这个请求就由wp根目录的`index.php`去处理好了, 它是wp的入口文件, 会自己解析的.

于是$uri就变成了`/index.php`, 这是一个被重写过的结果.

另外, 除了被`rewrite`与`try_files`重写, 当uri路径种出现`/abc//def/index.html`时, nginx还会首先将`$uri`重写成`/abc/def/index.html`, 虽然好像并没有什么用...咳.

### 1.3 `$request_filename`

虽然同样加了`request`前缀, 却跟`$request_uri`相反, 它是经过处理之后的值. 上面说到Nginx没有找到原始uri, 它把请求都交给了`/index.php`, 所以`$request_filename`就是`/var/www/html/index.php`了(`/var/www/html`是我在nginx配置文件中使用`root`指令指定的wp的根目录). 相当于实际请求的文件.

### 1.4 `$fastcgi_script_name`

这个是Nginx以fastcgi模式处理PHP请求的配置, 这个就没什么为什么了. 就是实际处理请求的PHP文件. 见过下面的经典配置么?

```
location ~ \.php$ {
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  $request_filename;
    ## fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
    fastcgi_param  QUERY_STRING $query_string;
    include        fastcgi_params;
}
```

这是将请求转发给本地的php-fpm的指令, 看上面被注释掉的行, 其实它也是正确的. 因为`$request_filename` == `$document_root$fastcgi_script_name`.

### 1.5 `$document_uri`

还没见过, 看起来也是实际生成响应的文件路径, 与`$uri`相同.

## 2. 其他变量

好了, 第一节中的变量是url访问路径相关的, 剩下的基本是HTTP协议的Header信息, 有一些Nginx的日志部分可能会用到. 日志中变量的使用方法如下

```
http{

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    server {
        ...省略
        access_log  /var/log/access.log  main;
    }
}
```

在`main`格式中可添加不同的变量, 重启后可以在输出日志中看到每个访问请求的相关变量内容.

------

$content_length	          请求头中的`Content-length`字段

$content_type	            请求头中的`Content-Type`字段

$host	                    浏览器请求头中的`Host`字段，否则为服务器名称

$http_referer	            请求头中的`Referer`字段, 用来记录从那个页面链接访问过来的

$http_user_agent	        客户端agent信息

$http_cookie	            客户端cookie信息

$request_method	          客户端请求的动作，通常为GET或POST

$remote_addr	            客户端的IP地址(若经过代理的话就是代理服务器的IP)

$remote_port	            客户端的端口

$remote_user	            已经经过Auth Basic Module验证的用户名

$server_protocol	        请求使用的协议版本, 通常是`HTTP/1.0`或`HTTP/1.1`

$server_addr	            服务器地址，在完成一次系统调用后可以确定这个值

$server_name	            服务器名称, 指的是在`server{}`块中`server_name`字段的设置值.

$server_port	            请求到达服务器的端口号

$http_x_forwarded_for	    客户端源IP(即使经过代理, 此值也将指向客户端自己IP)

$time_local	                访问时间与时区

$body_bytes_sent	        记录发送给客户端文件主体内容大小

$limit_rate	              这个变量可以限制连接速率（不知道怎么用）

$request_body_file	      客户端请求主体信息的临时文件名（没懂）

$request_body              客户端POST请求体中携带的数据

$document_root            配置文件中`root`指令的值, 网站的根目录.

$nginx_version            nginx版本

------

$scheme	                  协议类型(如`http`, `https`)

$request	               从结果来看,这个值等与`$request_method` + `$request_uri` + `$server_protocol`

$status	                  响应状态码

$request_time	            响应时间

------

$upstream_addr              转发到后端服务器的地址(貌似只有ip和端口...)

$upstream_status            后端服务器返回的状态码

$upstream_response_time     后端服务器响应时间

$upstream_response_length   后端服务器响应长度

[nginx内置变量列表](http://nginx.org/en/docs/varindex.html)
