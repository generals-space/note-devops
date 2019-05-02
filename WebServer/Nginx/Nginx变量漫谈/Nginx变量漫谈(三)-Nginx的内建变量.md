# Nginx变量漫谈(三)-Nginx的内建变量

前面我们接触到的都是通过set指令隐式创建的Nginx变量. 这些变量我们一般称为`用户自定义变量`, 或者更简单一些, `用户变量`. 既然有`用户自定义变量`, 自然也就有由Nginx核心和各个Nginx模块提供的`预定义变量`, 或者说`内建变量`(builtin variables).

Nginx内建变量最常见的用途就是获取关于请求或响应的各种信息. 例如由`ngx_http_core`模块提供的内建变量`$uri`, 可以用来获取当前请求的URI(经过解码, 并且不含请求参数), 而`$request_uri`则用来获取请求最原始的URI(未经解码, 并且包含请求参数).

请看下面这个例子(这里为了简单起见, 连server配置块也省略了):

```conf
location /test {
    echo "uri = $uri";
    echo "request_uri = $request_uri";
}
```

和前面所有示例一样, 我们监听的依然是8080端口. 在这个例子里, 我们把`$uri`和`$request_uri`的值输出到响应体中去. 下面我们用不同的请求来测试一下这个`/test`接口:

```
$ curl 'http://localhost:8080/test'
uri = /test
request_uri = /test
 
$ curl 'http://localhost:8080/test?a=3&b=4'
uri = /test
request_uri = /test?a=3&b=4
 
$ curl 'http://localhost:8080/test/hello%20world?a=3&b=4'
uri = /test/hello world
request_uri = /test/hello%20world?a=3&b=4
```

另一个特别常用的内建变量其实并不是单独一个变量, 而是有无限多变种的一群变量, 即名字以`arg_`开头的所有变量, 我们估且称之为`$arg_XXX`变量群. 一个例子是`$arg_name`, 这个变量的值是当前请求名为`name`的URI参数的值, 而且还是未解码的原始形式的值.

来看一个比较完整的示例:

```conf
location /test {
    echo "name: $arg_name";
    echo "class: $arg_class";
}
```

然后在命令行上使用各种参数组合去请求这个`/test`接口:

```conf
$ curl 'http://localhost:8080/test'
name: 
class: 
 
$ curl 'http://localhost:8080/test?name=Tom&class=3'
name: Tom
class: 3
 
$ curl 'http://localhost:8080/test?name=hello%20world&class=9'
name: hello%20world
class: 9
```

其实`$arg_name`不仅可以匹配`name`参数, 也可以匹配`NAME`参数, 抑或是`Name`, 等等. Nginx会在匹配参数名之前, 自动把原始请求中的参数名调整为全部小写的形式.

如果你想对URI参数值中的`%XX`这样的编码序列进行解码, 可以使用第三方`ngx_set_misc`模块提供的`set_unescape_uri`配置指令:

```conf
location /test {
    set_unescape_uri $name $arg_name;
    set_unescape_uri $class $arg_class;

    echo "name: $name";
    echo "class: $class";
}
```

现在再看一下效果:

```
$ curl 'http://localhost:8080/test?name=hello%20world&class=9'
name: hello world
class: 9
```

空格果然被解码出来了!

从这个例子我们同时可以看到, 这个`set_unescape_uri`指令也像`set`指令那样, 拥有自动创建Nginx变量的功能. 后面我们还会专门介绍到 `ngx_set_misc`模块.

像`$arg_XXX`这种类型的变量拥有无穷无尽种可能的名字, 所以它们并不对应任何存放值的容器. 而且这种变量在Nginx核心中是经过特别处理的, 第三方Nginx模块是不能提供这样充满魔法的内建变量的.

类似`$arg_XXX`的内建变量群还有不少, 比如用来取cookie值的`$cookie_XXX`变量群, 用来取请求头的`$http_XXX`变量群, 以及用来取响应头的`$sent_http_XXX`变量群. 这里就不一一介绍了, 感兴趣的读者可以参考`ngx_http_core`模块的官方文档.

需要指出的是, **许多内建变量都是只读的**. 比如我们刚才介绍的`$uri`和`$request_uri`. **对只读变量进行赋值是应当绝对避免的, 因为会有意想不到的后果**, 比如:

```
location /bad {
    set $uri /blah;
    echo $uri;
}
```

这个有问题的配置会让Nginx在启动的时候报出一条令人匪夷所思的错误:

```
[emerg] the duplicate "uri" variable in ...
```

如果你尝试改写另外一些只读的内建变量, 比如`$arg_XXX`变量, 在某些Nginx的版本中甚至可能导致进程崩溃.

