# Nginx自定义响应头和状态码

## 1. 响应头

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

## 2. 状态码

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

不过, `return`的返回值不可以是字符串, 像`return 'hehe'`, 不能像`add_header`那么方便啊.
