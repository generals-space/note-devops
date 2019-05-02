# Nginx-server_name匹配规则

## 1 情景描述

当前有顶级域名`example.com`, `www`与`bbs`为合法子域名, 可分别访问主页和论坛, `nginx`配置如下. 现要求任何非法子域名(如`jkl.example.com`等**未由`nginx`的`server`块显示配置的子域名**)由`nginx`返回404.

咳, 这个要求看起来有点搞笑, 禁止非法子域名访问只要不开启域名泛解析就行了, 何必要由nginx返回404呢.

```
http {
    ...
    server {
        listen 80;
        server_name www.example.com;
        ...
    }
    server {
        listen 80 default_server;
        server_name bbs.example.com;
        ...
    }
}
```

## 2 解决方法

### 2.1 打开泛解析

首先在域名服务器打开域名泛解析, 即`*.example.com`要全部指向目标服务器IP, 在`nginx`未作任何其他配置时, 访问其他非法子域名如`jkl.example.com`, 会指向`nginx`配置文件中带有**`default_server`**标记的`server`块所声明的域名. 即上面的`bbs.example.com`.

另外, 如果整篇配置文件中都没有`default_server`标记, `nginx`将会返回配置文件中出现的第1个的`server`块(**不管是不是相同的顶级域名**). 比如移除上面配置中`bbs`子域名的`default_server`标记, 再次访问`jkl.example.com`将会返回`www.example.com`.

### 2.2 nginx配置

配置`nginx`, 让所有其他非法域名都返回404. 有三种方法, 就是上面说到的`default_server`标记和首部插入`server`块, 还有就是`server_name`域名通配.

**`default_server`标记**

在配置文件`http`块中任何位置添加如下内容. 因为在`nginx`中`default_server`标识唯一, 所以使用这种方法时需要将其他`default_server`标记删除, 这对域名指向的**正确性**没有影响.

```
server {
    listen 80 default_server;
    server_name _;
    return 404;
}
```

其实, 有了`default_server`标记, `server_name`字段实际上也不需要了. 但是在一些情况下, `server_name`其实还是有用的, 比如多个顶级域名情况下, 需要只对其中某一个顶级域名的非法子域名返回404时.

**插入`server`块**

在`http`块中添加如下内容(相比以上只是少了`default_server`标记), 要确保`nginx`配置文件中没有其他`default_server`块并且一定要是`http`中第1个`server`块. 当然, 这种方法也不需要`server_name`字段. 不过如果是多个顶级域名时, 可能会出现访问`jkl.example2.com`而得到`www.example.com`的情况. 第1个`server`块嘛, 都跨域名匹配了...

```
server {
    listen 80;
    server_name _;
    return 404;
}
```

**`server_name`域名通配**

这个感觉比较好懂, 就是将`server_name`设置为`*.example.com`然后`return 404`就可以了. 这也算是显示的指明了子域名了.

------

这3种方式都是将由DNS服务器指来的访问域名地址, 与`nginx`配置文件中有**显示声明**的`server`块进行匹配, 所有其他未显式在`server`块中声明的子域名(如果有多个顶级域名, 那就是全部顶级域名未显式声明的非法子域名), 都会被这3种方式捕捉到.

不过直觉上来说, 感觉第2种不太好啊.

## 3 扩展

再考虑一种情况, 所有`example.com`子域名都监听`80`端口, 另外还有`example2.com`监听`8080`, 它们两个都分别有`www`与`bbs`子域名. 怎样设置`nginx`对这两个顶级域名的非法子域名都返回404?

上面说过, `default_server`标记在配置文件中是唯一的, 但我尝试了在`www.example.com`与`www.example2.com`所在的`server`块中`listen`字段都加了这个标记, 没有发生错误, 同时生效, 可以说**default标记对同一端口才是唯一的**.

`nginx`会根据端口值准备好为请求服务的`server`块, 不是对应端口的绝不处理. 比如当前这个例子, 设置`nginx`泛解析方面配置如下. 整个配置文件中只有这一个`default_server`标记, 没有对80端口做泛解析. 你说`jlk.example.com`能不能被下面这个**default_server**捕捉到? 这个请求是80端口的哦.

```
server {
    listen 8080 default_server;
    server_name _;
    ...
}
```

答案是不会, 谁让请求不能跨端口呢? `example.com`由于dns开了泛解析, 在没有80端口的`default_server`情况下, 只能寻找配置文件中的第一个监听80端口的`server`块了.

我都不知道这样是好还是不好了, 看起来nginx处理请求是很有原则的, 值得肯定.

但如果我不只有两个顶级域名呢? 如果我有20个顶级域名(分别监听不同端口), 它们都需要对非法子域名返回404呢? (虽然这个问题真的很扯--开泛解析是为了什么!?) 我是需要为每个正在监听的端口都再添加一个带`default_server`标记的`server`块呢, 还是在`http`块开头部分为它们添加第1个匹配的`server`块呢, 还是为它们分别添加顶级域名通配呢? 这3个不管哪种, 都需要添加20个`server`块呀...

> PS: **nginx的域名匹配流程**--**`server_name`的下划线**

> 它有什么作用呢? 它可以作为未显式在配置文件中声明的域名匹配, 但匹配流程次序的干扰太多了.

> 首先它不能跨端口匹配域名请求, 所以下面都假设是相同端口. 

> 在设置其他`server`块为`default_server`时, 非法子域名也只会匹配到`default_server`所在的`server`块, 然后下面假设不存在`default_server`标记. 就算不存在`defalut_server`, 它的优先级也不如`*.example.com`高, 因为后者相当于显示设置了域名匹配. 但就算没有`*.example.com`这种形式, 非法子域名匹配的也不是下划线`server`块, 而是`http`中第1个`server`块. 这样看来, 它的使用情况实在有限啊.
