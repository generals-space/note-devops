# Nginx错误-502 504 Gateway问题

参考文章

[Nginx 502错误原因和解决方法总结](http://www.server110.com/nginx/201312/4409.html)

在普通的`Linux+Nginx+PHP(php-fpm)+MySQL`的架构中, 未根据服务器自身性能进行优化时, 当网站访问量增加, 系统负载变大时, 很容易出现502/504错误. 大多数与Nginx本身无关.

1. `Nginx 502 Bad Gateway`的含义是请求的`PHP-CGI`已经执行, 但是由于某种原因(一般是读取资源的问题)没有执行完毕而导致PHP-CGI进程终止.

2. `Nginx 504 Gateway Time-out`的含义是所请求的网关没有请求到, 简单来说就是没有请求到可以执行的PHP-CGI.

> 解决这两个问题其实是需要综合思考的, 一般来说`Nginx 502 Bad Gateway`和`php-fpm.conf`的设置有关, 而`Nginx 504 Gateway Time-out`则是与`nginx.conf`的设置有关. 而正确的设置需要考虑服务器自身的性能和访客的数量等多重因素.

## 1. 问题分析

### 1.1 Nginx 502 Bad Gateway

咳, 首先一点, 确定`php-fpm`进程已经启动, 且`proxy_pass/fastcgi_pass`配置正确(这种一般出现在初次配置的时候).

既然是请求已经被执行, 就说明问题存在于**PHP代码执行期间**, 或是**php-fpm将执行结果返回**这两个阶段.

**1. php-fpm执行时间过长**

可能是由于php代码本身有问题(如陷入死循环), 或者数据库读写时间过长(数据库本身也有锁机制), 从而长时间无法得到执行结果.

**2. fastcgi请求, 发送, 读取超时**

可能是系统繁忙, 与FastCGI沟通时间过长

**3. fastcgi响应读取失败或超时**

一般是由于Nginx中的buffer不足, FastCGI的响应被缓冲到磁盘, 减慢了读取速度.

### 1.2 Nginx 504 Gateway Time-out

这个错误的含义是**没有请求到可以使用的CGI**. 那就可能是

**1. php-fpm进程数量不足**

可能是max_children设置值较小, 其余都在"忙"

**2. php-fpm进程占用时间过长**

可能是php代码有bug, 也可能是数据库读取过慢. 总之占用时间过长, 导致该进程迟迟无法生成响应, 也不能接受其他请求.

## 2. 相关配置

### 2.1 Nginx方面

Nginx处于等待与接收结果的角色, 所以一般502错误在Nginx端解决.

针对产生`502`原因的第1条和第2条, 可以规定PHP-CGI的连接, 发送和读取的时间, 300秒足够用了.

```conf
fastcgi_connect_timeout 300s;
fastcgi_send_timeout 300s;
fastcgi_read_timeout 300s;
```

针对产生`502`原因的第3条, 可以调整nginx缓冲区大小, 相关配置如下

```conf
fastcgi_buffer_size 128k;
fastcgi_buffers 8 128k;
fastcgi_busy_buffers_size 256k;
fastcgi_temp_file_write_size 256k;
```

### 2.2 php-fpm方面

php-fpm处于处理请求/响应结果的角色, 504错误在php-fpm端解决.

对504错误的第1项, 可以调整`max_children`选项, 设置合理的子进程值.

对504错误的第2项, 可以设置如下选项

```conf
request_terminate_timeout 60s ##默认为0s
```

这是为了防止php代码本身存在bug, 使php-fpm进程无法得到释放. 默认为0s是指可以让php-fpm进程一值执行, 没有时间限制

## 3. 优化原则

**正确的设置需要考虑服务器自身的性能和访客的数量等多重因素**.

理论上max_children选项值越大越好, 过小会造成排队, 而且php-fpm进程处理的也会很慢

但实际上要根据服务器的内存配置设置, 一个php-fpm进程大概占用20M的内存,  这个值过大的话反而会让服务器因内存不足崩溃或将进程杀死.

缓冲区的设置也是如此, 这个值也要根据响应页面的大小设置, 过小会导致缓冲到硬盘, 读取速度降低; 过大则会造成资源浪费.
