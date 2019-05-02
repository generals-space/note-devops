# Nginx访问规则-location详解

参考文章

[Nginx之location 匹配规则详解](http://www.cnblogs.com/lidabo/p/4169396.html)

> 当`server`块内同时存在正则形式与普通形式的`location`匹配规则时, 会优先匹配普通形式的location.

我们知道, `location`与`if`的匹配规则都有如下几种

1. 没有任何符号 表示普通匹配, 可作为路径前缀匹配

2. `=` | `!=` 表示精确匹配, 完全相等/不相等

3. `^~` 表示uri以某个常规字符串开头, 非正则匹配(...好像跟1没什么区别啊)

4. `~`|`!~` 表示区分大小写的正则匹配/不匹配

5. `~*`|`!~*` 表示不区分大小写的正则匹配/不匹配

## 1 普通匹配

上面5种情况, 前3种都是普通匹配.

在第1种普通匹配中, 默认是匹配所有普通匹配项里最长最准确的那一个. 比如

```
location /main {

}
location /main/abc {

}
```

当用户访问的uri为`/main/abc/index.php`, 将匹配到第2条`location`. 这一点很容易理解.

另外`=`的级别高于`^~`, 也高于什么都不写的时候. 例如

```
location = /main/ {

}
location ^~ /main/ {

}

location = /abc_def/{

}
location ^~ /abc_{

}
```

当用户访问`/main/`时, 将会匹配到第1条; 当访问`/abc_def/`时将会匹配到第3条.

同理, 无符号最长路径uri也将高于`^~`指定的前缀匹配. 例如

```
location /main/abc{

}
location ^~ /main/ {

}
```

用户访问`/main/abc/index.html`时, 将匹配到第1条. 这与`location`放置的先后顺序无关.

```
location = / {

}
location / {

}
```

这样, 网站根路径可以是单独的处理规则, 其他路径则是另外一种规则.

## 2 正则匹配

正则匹配按照在配置文件的先后顺序进行, 一旦匹配成功, 就不再继续向下执行匹配了. 这一点与普通匹配不同, 所以, 有相同前缀的正则表达式, 还是把较长的项放在前面吧.

比如

```
location ~* ^/([^\/_]*)_([^\/_]*)/main/(.*)$ {
    proxy_pass http://backend/$3;
}   
location ~* ^/([^\/_]*)_([^\/_]*)/(.*)$ {
    proxy_pass http://frontend/$3;
}
```

以上正则匹配的是以类似于`/abc_def/`, `/lmn_xyz/`为前缀的uri, 如果是`/abc_def/main/index.html`将会把请求的`index.html`部分转发至名为`backend`的`upstream`池, 如果是`/abc_def/index.html`则会将`index.html`部分转发至名为`frontend`的`upstream`池.

注意: 如果将两个`location`块调换位置, 所有以类似于`/abc_def/`为前缀的uri都将被转发至`frontend`, 不管`/abc_def`后有没有`/main`路径. 这就是正则匹配的位置决定顺序的特性.

## 3 混合

如果配置文件中同时存在普通匹配与正则匹配, nginx会**优先完成普通匹配**, 然后进行正则匹配, 所以普通匹配的优先级是大于正则匹配的.

但是这样的话, 如果一个uri同时满足普通匹配与正则匹配, 将会执行后者的操作. 所以说, **优先级高不代表最终以其为准**.

那如果希望普通匹配与正则匹配同时满足的情况下执行前者指定的操作, 怎么办?

普通匹配中`=`与`^~`就可以达到这个目的, 当完成以这两个符号开始的普通匹配后, 将不再执行正则匹配. 但是它们并不阻止继续进行普通匹配, 也就是说仍然会按照最长最准确的`location`进行操作, 所以, 要达到终止正则匹配的目的, 需要在最长的`location`字符串前使用`^~`.

先看第1个例子, 依然与2.2节中的正则匹配有关.

```
location ~* ^/([^\/_]*)_([^\/_]*)/main/(.*)$ {
    proxy_pass http://backend/$3;
}   
location ~* ^/([^\/_]*)_([^\/_]*)/(.*)$ {
    proxy_pass http://frontend/$3;
}
location /abc_def/{

}
```

当用户访问`/abc_def/index.html`, nginx将先进行第3条`location`匹配, 之后执行第1, 2条, 于是最后匹配到第2条.

第2个例子.

```
location ~* ^/([^\/_]*)_([^\/_]*)/main/(.*)$ {
    proxy_pass http://backend/$3;
}   
location ~* ^/([^\/_]*)_([^\/_]*)/(.*)$ {
    proxy_pass http://frontend/$3;
}
location = /abc_def/ {

}
location ^~ /abc_def/{

}
```

当用户访问`/abc_def/`, 将匹配到第3条, 由此也可以看出同样匹配字符串情况下, `=`的级别高于`^~`; 如果访问`/abc_def/index.html`, 将匹配到第4条.

无论哪一种, 都不会在进行正则方式的`location`匹配.

第3个例子.


```
location ~* ^/([^\/_]*)_([^\/_]*)/main/(.*)$ {
    proxy_pass http://backend/$3;
}   
location ~* ^/([^\/_]*)_([^\/_]*)/(.*)$ {
    proxy_pass http://frontend/$3;
}
location ^~ /abc_{

}
location /abc_def/{

}
```

如果用户访问`/abc_def/index.html`, nginx将会先匹配到第3条, 然后继续进行普通匹配, 于是到了第4条, 但是第4条并没有以`=`或`^~`开头, 所以匹配到这里后, 还会继续进行正则匹配, 与是最终还是会到第2条.
