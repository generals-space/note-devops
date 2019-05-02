# Nginx重定向rewrite理解

语法

```
rewrite 源字符串(一般为正则)  目标字符串  标识位
```

首先`rewrite`有4种标志位: `last`|`break`|`redirect`|`permanent`, 这.

其中`redirect`与`permanent`分别为301和302重定向, 而`last`|`break`更适合被称为 **url重写**. 区别在于

- 重定向会为当前请求返回`301`|`302`代码, 并在响应头`Location`字段中填写上`替换url`, 这将引起浏览器再次发起一次http请求(如果客户端是`curl`等命令就算了), 目标就是这个`Location`字段中重定向的url.

- url重写完成后会以重写后的url在nginx配置文件中继续匹配, 而不是像重定向那样干脆返回一个`Location`字段让浏览器再发起一次请求.

## 1. rewrite重写规则

不管是重定向还是重写, `rewrite`指令的`源字符串`部分匹配的只会是`uri`路径部分, 不包括域名, 端口和请求参数. 所以匹配时是无法匹配到`http://`字段或是域名信息的, 这样会导致匹配失败. 如果必须要根据域名, 端口等进行匹配, 建议结合`if`指令使用.

而替换的`目标字符串`目前发现的有3种格式可选:

- 以`http://域名[:端口]`开头的全路径.

- 以`/`开头的绝对路径, 将会以当前访问域名为前缀进行拼合.

- 不带`/`的路径, 这将会被视为以当前请求资源为准的相对路径, 会与当前资源的访问路径进行拼合.

原访问路径的请求参数不会被重写, 它默认追加到重写后的`uri`后面, 如果想舍弃原来的请求参数, 在`替换字符串`部分末尾加上'?'即可.

## 2. last与break的区别

参考文章

[nginx rewrite规则语法](http://blog.csdn.net/xiao_jun_0820/article/details/9397011)

我们知道, `rewrite`合法位置在`server`, `if`, `location`块内. 并且上面也说了, `last`与`break`的`rewrite`称为 **url重写** 更为贴切. 我们首先要理解url重写之后的处理流程.

假设nginx安装在`/usr/local/nginx`, 这样在nginx配置文件中使用`root html;`可以指定目标目录为`/usr/local/nginx/html`.

第1个例子. `rewrite`指令只出现在`if`块内.

在`html`目录下创建`download/music/index.html`, 并在该文件中写入`download/music/index.html`; 然后继续在`html`目录下创建`music/index.html`, 在其中写入`music/index.html`;

```
server {
    root html;
    if ($request_uri ~* ^/download){
        rewrite ^(/download)(.*)$ $2 last;
    }
    location /music/ {
        add_header request_uri $request_uri;
        add_header uri $uri;
    }   
}
```

我们访问`/download/music/index.html`, `if`语句会将其重写成`/music/index.html`, 继续匹配到`location`, 然后页面上显示的为`/music/index.html`, 这应该不难理解. nginx内置变量`$request_uri`表示请求的原始uri, 不可更改, 而`$uri`表示被`rewrite`/`try_files`重写后的值, 我们在浏览器中可以看到此页面的响应头中多了两个自定义的字段: `request_uri`与`uri`, 分别为`/download/music/index.html`与`/music/index.html`. 也印证了我们的猜测.

然后, 添加另外的条件, 将上面的配置修改为如下

```conf
server {
  root html;
  if ($request_uri ~* ^/download){
      rewrite ^(/download)(.*)$ $2 last;
  }
  if ($uri ~* ^/music){
      rewrite ^(/music)(.*)$ https://www.taobao.com redirect;
  }
  location / {
      add_header request_uri $request_uri;
      add_header uri $uri;
  }
}
```

好吧, 上面第2,3个`if`语句, 是为了验证`if`语句块中的`rewrite`是不是按照顺序来的. 第2,3条匹配的变量是`$uri`, 如果是按顺序来的, 访问`/download/music/index.html`, 页面应该会被重定向到淘宝网.

然而事实是, 页面显示的是`/music/index.html`, 即, **经`if`(也包多`server`块本身的)语句块中的`rewrite`指令, 一旦修改, 就会直接去匹配`location`, 之后任何其他的`if`匹配都不会执行...!!!**.

细思极恐的一点是...也许`if`块内`rewrite`重写之后, `if`语句与`location`语句之间的任何操作都不会执行...

```conf
server {
  root html;
  set $abc '123456';
  if ($request_uri ~* ^/download){
      rewrite ^(/download)(.*)$ $2 last;
  }
  ## set $abc '123456';
  location / {
      add_header request_uri $request_uri;
      add_header uri $uri;
      add_header abc $abc;
  }
}
```

访问`/download/music/index.html`, 返回的页面上还是`/download/music/index.html`, 而且响应头多了自定义字段`abc`, 值为`123456`; 尝试将`if`语句上面的`set`指令注释掉, 解开下面的`set`指令的注释, 刷新页面...响应头里没有`abc`字段了. 也就是说, **`if`与`server`块内的`rewrite`一旦完成url重写, 就立刻去匹配`location`, 之间的任何操作都不会执行**.

然后我们尝试将`if`块中`rewrite`的`last`标志位换成`break`, 再次重复上面的操作, 你会发现情况与使用`last`标记时完全相同, 因为`last`与`break`在`if`,`server`块内表现没有任何区别. 这两个地方出现的`rewrite`次数多了还会按顺序执行. **它们的区别在与`location`块内的使用.**

------

第2个例子, `rewrite`同时出现在`if`块与`location`块内. `html`目录结构与上面一个例子相同.

```conf
server {
  root html;
  if ($request_uri ~* ^/download){
      rewrite ^(/download)(.*)$ $2 last;
  }
  location /music/ {
      rewrite ^(.*)$ /download$1 last;
  }
}
```

我们还是访问`/download/music/index.html`, `if`语句将其修改为`/music/index.html`, 匹配到`location`, `location`块又将其重写成了`/download/music/index.html`, 但是之后并没有再次从`if`语句进行重写, 因为如果那样的话相当于陷入了死循环, 而实际上页面上显示了`/download/music/index.html`.

将`location`内中的`last`标记修改为`break`, 结果不变.

再进一步, 我们再添加一段`/download`的`location`匹配.

```conf
server {
  root html;
  if ($request_uri ~* ^/download){
      rewrite ^(/download)(.*)$ $2 last;
  }
  location /music/ {
      rewrite ^(.*)$ /download$1 last;
  }
  location /download/ {
      rewrite ^(/download)(.*)$ $2 last;
  }
}
```

再次访问`/download/music/index.html`, 不出意外的话, 将得到500错误;

将第1个`location`中的`last`标记修改成`break`, 第2个保持`last`不变, 刷新页面, 将得到`/download/music/index.html`;

将第2个`location`中的`last`标记修改成`break`, 第2个保持`last`不变, 刷新页面, 将得到`/music/index.html`.

这就是`last`与`break`的区别了, 这点区别只在`location`块内有所表现.

- `last`: url重写完成后立即结束当前`location`内的`rewrite`检测, 并且以重写后的uri继续对所有(包括本身)的`location`再次匹配;

- `break`: url重写完成后立即结束当前`location`内的`rewrite`检测, 并且不再匹配任何`location`与`if`语句, 直接以重写后的url为路径去访问目标文件.

上面的第1种情况, `if`语句将`/download/music/index.html`重写成`/music/index.html`, 匹配到第1个`location`, 又将其修改成`/download/music/index.html`, 虽然不再匹配上面的`if`语句, 但`last`标记表示结束当前`location`的`rewrite`匹配, 但又开始重新对所有`location`匹配, 于是这两个`location`之间陷入了死循环, nginx内部设置了`rewrite`的最大次数为10, 超过这个值就会返回500.

第2种情况, `if`语句将`/download/music/index.html`重写成`/music/index.html`, 匹配到第1个`location`, 又将其修改成`/download/music/index.html`, 此时`break`的作用就体现出来了, 它停止了当前`location`的所有`rewrite`, 直接去寻找`html`根目录下`/download/music/index.html`文件, 于是...

那第3种情况也很容易理解了...

这就是`last`与`rewrite`的区别了.

## 3. 总结

1. `rewrite`正则部分匹配的是uri部分, 不包括`http(s)://`, 域名, 端口信息, 确切一点说, 这个部分最终匹配到的是当前nginx内部的`$uri`变量, 而`$uri`随着nginx的处理流程, 是可以被修改的.

2. location中正则匹配分组是可以被该location块内部的语句引用的.
