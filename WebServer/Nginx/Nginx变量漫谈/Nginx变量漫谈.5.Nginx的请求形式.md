# Nginx变量漫谈(五)-Nginx的请求形式

## 5.1 主请求与子请求

前面在`chapter 2`中我们已经了解到变量值容器的生命期是与请求绑定的, 但是我当时有意避开了"请求"的正式定义. 大家应当一直默认这里的"请求"都是指客户端发起的HTTP请求. 其实在Nginx世界里有两种类型的"请求", 一种叫做"主请求"(main request), 而另一种则叫做"子请求"(subrequest). 我们先来介绍一下它们.

所谓`主请求`, 就是由HTTP客户端从Nginx外部发起的请求. 我们前面见到的所有例子都只涉及到`主请求`. 包括(二)中那两个使用 `echo_exec`和`rewrite`指令发起`内部跳转`的例子.

而`子请求`则是由Nginx正在处理的请求在Nginx内部发起的一种**级联请求**. `子请求`在外观上很像HTTP请求, 但实现上却和HTTP协议乃至网络通信一点儿关系都没有. 它是Nginx内部的一种抽象调用, 目的是为了方便用户把`主请求`的任务分解为多个较小粒度的`内部请求`, 并发或串行地访问多个location接口, 然后由这些location接口通力协作, 共同完成整个`主请求`. 当然, `子请求`的概念是相对的, 任何一个`子请求`也可以再发起更多的`子子请求`, 甚至可以递归调用(即自己调用自己). 当一个请求发起一个`子请求`的时候, 按照Nginx的术语, 习惯把前者称为后者的`父请求`(parent request). 值得一提的是, Apache服务器中其实也有`子请求`的概念, 所以来自Apache世界的读者对此应当不会感到陌生.

下面就来看一个使用了"子请求"的例子:

```conf
location /main {
    echo_location /foo;
    echo_location /bar;
}

location /foo {
    echo foo;
}

location /bar {
    echo bar;
}
```

这里在`location /main`中, 通过第三方`ngx_echo模块的echo_location`指令分别发起到`/foo`和`/bar`这两个接口的GET类型的`子请求`, 由`echo_location`发起的`子请求`, 其执行是按照配置书写的顺序串行处理的, 即只有当`/foo`请求处理完毕之后, 才会接着处理`/bar`请求. 这两个`子请求`的输出会按执行顺序拼接起来, 作为`/main` 接口的最终输出.

```conf
$ curl 'http://localhost:8080/main'
foo
bar
```

我们看到, "子请求"方式的通信是在同一个虚拟主机内部进行的, 所以Nginx核心在实现"子请求"的时候, 就只调用了若干个C函数, 完全不涉及任何网络或者UNIX套接字(socket)通信. 我们由此可以看出"子请求"的执行效率是极高的.

## 5.2 父子请求之间的变量值容器

回到先前对Nginx变量值容器的生命期的讨论. 我们现在依旧可以说, 它们的生命期是与当前请求相关联的. 每个请求都有所有变量值容器的独立副本, 只不过当前请求既可以是"主请求", 也可以是"子请求". 即便是父子请求之间, 同名变量一般也不会相互干扰. 让我们来通过一个小实验证明一下这个说法:

```conf
location /main {
    set $var main;

    echo_location /foo;
    echo_location /bar;

    echo "main: $var";
}

location /foo {
    set $var foo;
    echo "foo: $var";
}

location /bar {
    set $var bar;
    echo "bar: $var";
}
```

在这个例子中, 我们分别在`/main`，`/foo`和`/bar`这三个location配置块中为同一名字的变量-`$var`, 分别设置了不同的值并予以输出. 特别地, 我们在`/main` 接口中, 故意在调用过`/foo`和`/bar`这两个"子请求"之后, 再输出它自己的`$var`变量的值. 请求`/main`接口的结果是这样的:

```
$ curl 'http://localhost:8080/main'
foo: foo
bar: bar
main: main
```

显然, `/foo`和`/bar`这两个"子请求"在处理过程中对变量`$var`各自所做的修改都丝毫没有影响到"主请求"`/main`. 于是这成功印证了"主请求"以及各个"子请求"都拥有不同的变量`$var`的值容器副本.

不幸的是, 一些Nginx模块发起的"子请求"却会自动共享其"父请求"的变量值容器, 比如第三方模块`ngx_auth_request`. 下面是一个例子:

```conf
location /main {
    set $var main;
    auth_request /sub;
    echo "main: $var";
}

location /sub {
    set $var sub;
    echo "sub: $var";
}
```

这里我们在/main接口中先为$var变量赋初值main, 然后使用ngx_auth_request模块提供的配置指令auth_request, 发起一个到/sub接口的"子请求", 最后利用echo指令输出变量$var的值. 而我们在/sub接口中则故意把$var变量的值改写成sub. 访问/main接口的结果如下:

```
$ curl 'http://localhost:8080/main'
main: sub
```

我们看到, /sub接口对$var变量值的修改影响到了主请求/main. 所以ngx_auth_request模块发起的"子请求"确实是与其"父请求"共享一套Nginx变量的值容器.

对于上面这个例子, 相信有读者会问: "为什么子请求`/sub`的输出没有出现在最终的输出里呢?" 答案很简单, 那就是因为`auth_request`指令会自动忽略"子请求"的响应体, 而只检查"子请求"的响应状态码. 当状态码是2XX的时候. `auth_request` 指令会忽略"子请求"而让Nginx继续处理当前的请求, 否则它就会立即中断当前(主)请求的执行, 返回相应的出错页. 在我们的例子中, `/sub`子请求只是使用echo指令作了一些输出, 所以隐式地返回了指示正常的200状态码.

如`ngx_auth_request`模块这样父子请求共享一套Nginx变量的行为, 虽然可以让父子请求之间的数据双向传递变得极为容易, 但是对于足够复杂的配置, 却也经常导致不少难于调试的诡异bug. 因为用户时常不知道"父请求"的某个Nginx变量的值, 其实已经在它的某个"子请求"中被意外修改了. 诸如此类的因共享而导致的不好的"副作用", 让包括`ngx_echo, ngx_lua`, 以及ngx_srcache在内的许多第三方模块都选择了禁用父子请求间的变量共享.