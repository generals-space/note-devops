# nginx应用场景及相应配置

## 3. Nginx作反向代理处理后端服务器的301/302问题

### 3.1 场景描述

Nginx作反向代理服务器, 用户`U`通过nginx服务器`N`访问后端服务器`S`, 由`N`取得`S`的数据并将结果返回给用户`U`. 如果后端服务器返回`301/302`, 那N也将这`301/302`直接返回给用户.

现在的要求是当后端服务器`S`返回`301/302`时, 由`N`再向`S`发送一次请求, 直到取得的结果不是`301/302`, 才将结果返回给用户.

首先要说明的是, `301/302`不是出错, 但如果后端服务器`S`重定向的地址是`U`无法直接访问时(这种情况应该比较普便, 可以将`N`看作是前端防火墙), 用户`U`就会得到错误. 另外可能由于重定向, 重写后的`url`无法正确找到, 也会得到错误.

### 3.2 场景再现

有时由于后端服务器的`301/302`响应, 用户无法得到正确的结果, 举个例子来说明.

- 反向代理服务器`N`的IP为`192.168.1.100`;

- 后端服务器`S`的IP为`192.168.1.200`;

`N`的配置如下

```
server {
    listen       9100;

    location /some-prefix/ {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        ##  proxy_set_header Via "nginx";
            proxy_pass http://192.168.1.200:9200;
    }

}

```

`S`也用nginx作服务器(这个选择可以多样, 因为当前要解决问题的重点在于前端服务器), 其配置如下

```
server {
    listen      9200;
    location /some-prefix/ {
        rewrite ^/some-prefix/(.*) /some-prefix/some-suffix/$1 rewrite;
    }
    location /some-prefix/some-suffix/ {
        root /usr/share/html;
        index index.html index.php;
    }
}
```

对于这种应用场景的解释, `S`的`/usr/share/html`为网站根目录, 原来Web程序在网站根目录的`/some-prefix`目录下存放, 后来迁移到`/some-prefix/some-suffix`目录下, 于是使用`rewrite`进行重定向. 出于某种原因(比如后端服务器不是nginx, 是由Web程序自定义的重定向时), 无法让后端服务器在`rewrite`之后再次匹配本机的`location`字段的其他配置, 所以只能将`rewrite`之后的url返回并加上`302`码.

使用`N`作反向代理, 用户访问`192.168.1.100:9100/some-prefix`, 结果怎样呢? 浏览器地址栏显示`192.168.1.100:9200/some-prefix/some-suffix/`, 这是`N`的IP加上`S`的端口的组合, 很是奇异. 用户浏览器访问这个地址自然无法得到正确结果.

分析一下这种情况的原因, `rewrite`命令处理相对路径的url(以`/`为根, 不涉及`http://IP`或`http://域名`)时, `http://IP`或是`http://域名`与来源url保持一致, 所以返回给`N`与`U`的`host`地址是不变的, 依然是`192.168.1.100`. 不过端口貌似就是自己被访问到的端口了, 而这个组合返回给`N`是默认不会被处理直接转发给用户`U`的.

### 3.3 解决方案

解决方案是使用`proxy_*`系中的`proxy_redirect`指令, 它可以将`N`返回给用户的url进行改写...嗯, 好像与预想中的解决方案不同. 原来想使用反向代理`N`对后端`S`进行二次访问再返回给用户的方法没找到, 只能退而求其次了.

话说回来, `proxy_redirect`指令可以修改返回给用户的`Location`与`Refresh`字段(注意, 由nginx向后端服务器发送请求时, nginx本身也可看作是 **用户**). `301/302`重定向时都会带一个地址, 引导用户...的浏览器再次访问, 这个地址就存储在http协议的`Location`字段里.

它的使用方法与`rewrite`类似, 不过还不清楚是否支持正则, 应该是不支持的. `proxy_redirect Location字段中的一部分 想要替换成的部分`. 比如上面的出错示例中, 用户浏览器得到的`Location`为`http://192.168.1.100:9200/some-prefix/some-suffix/`, 我们只需要把`9200`替换成`9100`就行了, 这样就可以写成`proxy_redirect 9200 9100`. 咳, 开个玩笑, 事实上需要写为 **`proxy_redirect http://192.168.1.100:9200/ http://192.168.1.100:9100/`**. 这样, 用户得到的`Location`字段就会变成`http://192.168.1.100:9200/some-prefix/some-suffix/`了.

`N`的配置变为如下(就多了一行)

```
server {
    listen       9100;

    location /some-prefix/ {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        ##  proxy_set_header Via "nginx";
            proxy_redirect http://192.168.1.100:9200/ http://192.168.1.100:9100/;
            proxy_pass http://192.168.1.200:9200;
    }

}
```

实际情况中可能需求多种多样, 也许上面的方面并不适用, 但是只要知道用户得到的`Location`字段, 根据实际要访问的url地址进行比对, 重写一下还是不难的.

不过这样的场景真是...让人无语

## 5. Nginx不缓存

在开发调试web的时候, 经常因为浏览器缓存(cache)去清空缓存或者强制刷新...现在的问题是, 微信嵌入网页开发, 没找到禁止缓存的选项, 只能让服务器端配合了.

解决办法: Nginx配置文件里, url对应的location中加入`Cache-Control`字段

```shell
    location / {
        add_header Cache-Control no-store; ##注意add_header中间是下划线
        ...
    }
```

另外`add_header`这个指令还可以加自定义的响应头字段. 见下一小节.

## 6. Nginx自定义响应头

[参考文章](http://sumsung753.blog.163.com/blog/static/14636450120133794814985/)

`add_header`可以添加自定义响应头字段, 可以在浏览器响应头里面看到.

`add_header`指令的使用方式为`add_header key value`.

- `key`可以自定义, 不加引号, 作为键
- `value`可以为字符串, Nginx内置变量, 也可以是自定义变量

```shell
    location / {
        add_header hello 'world';               ##字符串
        add_header request_uri $request_uri;    ##Nginx内部变量
        set $abc 'cool';                        ##创建自定义变量, 以'$'起始, 类似于php
        add_header abc $abc;                    ##输出自定义变量
        ...
    }
```

我把这种作为一种**日志查看方式**, 尤其是对请求的location正则匹配与rewrite操作的结果, 可以不必去翻看日志转而将需要的信息以键值对的形式返回到浏览器响应头. 使用curl的`-I`选项访问目标路径打印响应头信息十分方便.

```shell
#curl -I localhost
...
request_uri: /
hello: world
abc: cool
...
```

**注意: 当为一个add_header指令设置的响应头的值为空时, 将没有办法看到结果.** 如果遇到设置了响应头为某变量, 但是访问结果中并没有输出, 可能是应为此变量的值为空了.

## 7. Nginx自定义状态码

来一个有意思的东西, 关于Nginx的`return`指令. 玩玩而已, 没有什么特别的功能.

我们可以手动指定某`location`或`server`字段等的`4xx`状态码, 并指定根据此状态码的值返回的页面(`errorpage`的作用); 或者对于`3xx`是通过`rewrite`指定代为完成的, 其中`permanent`与`redirect`分别代表`301`与`302`.

当我们手动返回一个状态码时, 比如

```shell
    server {
        ...
        ##errorpage 404 /404.html;
        location / {
            ...
            return 333;
        }
    }
```

这样, 在浏览器的响应头中会出现`333`代码, 一般接在`HTTP/1.1`后面, 像`HTTP/1.1 333`这样. 不过这样可能无法得到页面的正常显示, 想看到响应结果, 只能`curl -I 目标URL`.

不过, `return`的返回值不可以是字符串, 像`return 'hehe'`. 不能像`add_header`那么方便啊.


## 9. Nginx防盗链实现

参考文章

[nginx实现图片防盗链(referer指令)](http://www.ttlsa.com/nginx/nginx-referer/)

首先看一个例子

```
location ~* \.(jpg|png|gif){
  valid_referers none blocked *.test.com;
    if ($invalid_referer) {
        return 403;
    }
}
```

`valid_referers`指令指定了合法的`Referer`字段信息, 除了`*.test.com`是一个域名示例外, `none`表示请求头中`Referer`字段为空的情况, 例如从浏览器种直接访问该资源; `blocked`表示请求头`Referer`字段不为空, 但是里面的值被代理或者防火墙删除了，这些值都不以`http://`或者`https://`开头.

如果来源请求头部的`Referer`字段信息不在此列表中, 则将`$invalid_referer`变量的值置为1(默认貌似为空), 之后使用`if`语句定义这种情况下的处理方式.

`valid_referers`指令来自nginx的`ngx_http_referer_module`模块, 通常用于阻挡来源非法的域名请求. 但是, 伪装Referer头部是非常简单的事情，所以这个模块只能用于阻止大部分非法请求. 若有特殊要求可以使用第三方模块`ngx_http_accesskey_module`来实现公用key的防盗链，迅雷都可以防的哦亲...

## 10. 隐藏响应头中的nginx版本信息

由Nginx服务的请求在其响应的响应头中会有一个`Server`字段, 其值类似于`nginx/1.10.1`, 如果不希望客户端看到Nginx的版本信息, 可以在nginx配置文件里设置`server_tokens off;` 这样响应头的`Server`字段就只有`nginx`而没有版本号了.

## 11. Nginx访问控制/限制IP

使用nginx的`deny`/`allow`指令. 使用规则为

location / {
    deny  192.168.1.1;         ## 单一IP
    allow 192.168.1.0/24;    ## IP段
    allow 2001:0db8::/32;    ## IPv6
    deny  all;
}
类似于`iptables`, 匹配到就退出, 否则继续向下执行.

有效作用域为`http`, `location`, `server`.

但如果配置了CDN, 用户请求是通过CDN服务器转发的, 屏蔽用户来源IP是无效的. 此时需要通过用`if`语句判断`$http_x_forwarded_for`条件. 举例如下

```conf
if ( $http_x_forwarded_for ~* '^180\.97\.106\.' ) {
    return 403;
}
```

关于这个访问控制的最佳实践, 创建一个`block.ip`文件, 在主配置文件中调用, 之后添加新的访问控制时单独在这个文件中添加即可.

## 12. 开启浏览器端压缩传输

```conf
## 开启压缩传输
gzip on;
## 大于1K的才压缩，一般不用改
gzip_min_length 1k;

gzip_buffers 4 16k;

gzip_http_version 1.1;
## 压缩级别，1-10，数字越大压缩的越好文件越小，压缩时间也越长
gzip_comp_level 2;
## 指定需要压缩的文件类型. 可在浏览器响应头的`Content-Type`字段中查看(不同的教程好像文件meta类型也不一样, 根据实际情况来吧)
gzip_types text/plain application/javascript text/css application/xml text/javascript application/x-httpd-php
## 听说图片类型默认是压缩过的, 所以其实不用两次压缩
## image/jpeg image/gif image/png;
gzip_vary off;
## IE6不支持Gzip，不对它Gzip了
gzip_disable "MSIE [1-6]\.";
```

被压缩过的资源可以在浏览器响应头中查看, `Content-Encoding:gzip`, 且其值`Content-Length`.

如果想要压缩的数据没有被压缩, **请确认`gzip_types`中是否有指定正确的文件类型(`Content-Type`)**.

## 13. rewrite时expires指令生效的作用域

```
location / {
    root html;
    try_files $uri $uri/index.html /static;
}

location /static/ {
    root html/static;
}
```

`rewrite`指令或`try_files`发起的内部跳转行为, 还是比较独立的. 比如, 如果在第1个`location`块中加入`expires`指令, 那么当访问的uri被重写到`/static/`的块的时候, `/static`下返回的资源是不会被缓存的.

## 14. nginx记录post内容

```conf
## post_log为自定义日志名称, $request_body就是上传的文件内容
log_format post_log '$remote_addr - $request_body';
```

然后在需要的地方添加日志打印命令即可.

```conf
access_log  logs/skycmdb_post.log  post_log;
```