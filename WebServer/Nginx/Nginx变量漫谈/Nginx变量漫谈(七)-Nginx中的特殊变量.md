# Nginx变量漫谈(七)-Nginx中的特殊变量

在(一)中我们提到过, Nginx变量的值只有一种类型, 那就是字符串, 但是变量也有可能压根就不存在有意义的值. 没有值的变量也有两种特殊的值: 一种是"不合法"(invalid), 另一种是"没找到"(not found).举例来说:

当Nginx用户变量$foo创建了却未被赋值时, $foo的值便是"不合法";
而如果当前请求的URL参数串中并没有提及XXX 这个参数, 则$arg_XXX内建变量的值便是"没找到".

无论是"不合法"也好, 还是"没找到"也罢, 这两种Nginx变量所拥有的特殊值, 和空字符串("")这种取值是完全不同的. 比如JavaScript语言中也有专门的undefined和null这两种特殊值, 而Lua语言中也有专门的nil值. 它们既不等同于空字符串, 也不等同于数字0, 更不是布尔值false. SQL语言中的NULL也是类似的一种东西.

## 7.1 Invalid

虽然前面在chapter 1中我们看到, 由set指令创建的变量未初始化就用在"变量插值"中时, 效果等同于空字符串, 但那是因为set指令为它创建的变量自动注册了一个"取处理程序", 将"不合法"的变量值转换为空字符串.

为了验证这一点, 我们再重新看一下chapter 1中讨论过的那个例子(为了简单起见, 省略了原先写出的外围server配置块):

```conf
location /foo {
    echo "foo = [$foo]";
}

location /bar {
    set $foo 32;
    echo "foo = [$foo]";
}
```

在这个例子里, 我们在/bar接口中用set指令隐式地创建了$foo变量这个名字, 然后我们在/foo接口中不对$foo进行初始化就直接使用echo指令输出. 我们当时测试/foo接口的结果是

```
$ curl 'http://localhost:8080/foo'
foo = []
```

从输出上看, 未初始化的$foo变量确实和空字符串的效果等同. 但细心的读者当时应该就已经注意到, 对于上面这个请求, Nginx的错误日志文件(一般文件名叫做error.log)中多出一行类似下面这样的警告:

```
[warn] 5765#0: *1 using uninitialized "foo" variable, ...
```

这一行警告是谁输出的呢? 答案是set指令为$foo注册的"取处理程序". 当/foo接口中的echo指令实际执行的时候, 它会对它的参数"foo = [$foo]" 进行"变量插值"计算. 于是, 参数串中的$foo变量会被读取, 而Nginx会首先检查其值容器里的取值, 结果它看到了"不合法"这个特殊值, 于是它这才决定继续调用$foo变量的"取处理程序". 于是$foo变量的"取处理程序"开始运行, 它向Nginx的错误日志打印出上面那条警告消息, 然后返回一个空字符串作为$foo的值, 并从此缓存在$foo的值容器中.

细心的读者会注意到刚刚描述的这个过程其实就是那些支持值缓存的内建变量的工作原理, 只不过set指令在这里借用了这套机制来处理未正确初始化的Nginx变量. 值得一提的是, **只有"不合法"这个特殊值才会触发Nginx调用变量的"取处理程序", 而特殊值"没找到"却不会**.

上面这样的警告一般会指示出我们的Nginx配置中存在变量名拼写错误, 抑或是在错误的场合使用了尚未初始化的变量. 因为值缓存的存在, 这条警告在一个请求的生命期中也不会打印多次. 当然, `ngx_rewrite`模块专门提供了一条`uninitialized_variable_warn`配置指令可用于禁止这条警告日志.

## 7.2 Not Found

上面提到, 内建变量$arg_XXX在请求URL参数XXX并不存在时会返回特殊值"找不到", 但遗憾的是在Nginx原生配置语言(我们估且这么称呼它)中是不能很方便地把它和空字符串区分开来的, 比如:

```conf
location /test {
    echo "name: [$arg_name]";
}
```

这里我们输出$arg_name变量的值同时故意在请求中不提供URL参数name:

```
$ curl 'http://localhost:8080/test'
name: []
```

我们看到, 输出特殊值"找不到"的效果和空字符串是相同的. 因为这一回是Nginx的"变量插值"引擎自动把"找不到"给忽略了.

那么我们究竟应当如何捕捉到"找不到"这种特殊值的踪影呢? 换句话说, 我们应当如何把它和空字符串给区分开来呢? 显然, 下面这个请求中, URL参数name是有值的, 而且其值应当是空字符串:

```
$ curl 'http://localhost:8080/test?name='
name: []
```

但我们却无法将之和前面完全不提供name参数的情况给区分开.

### 7.2.1 区分Not Found与空值

幸运的是, 通过第三方模块ngx_lua, 我们可以轻松地在Lua代码中做到这一点. 请看下面这个例子:

```conf
location /test {
    content_by_lua '
        if ngx.var.arg_name == nil then
            ngx.say("name: missing")
        else
            ngx.say("name: [", ngx.var.arg_name, "]")
        end
    ';
}
```
这个例子和前一个例子功能上非常接近, 除了我们在/test接口中使用了`ngx_lua`模块的`content_by_lua`配置指令, 嵌入了一小段我们自己的Lua代码来对Nginx变量`$arg_name`的特殊值进行判断. 在这个例子中, 当`$arg_name`的值为"没找到"(或者"不合法")时, /foo接口会输出name: missing这一行结果:

```
curl 'http://localhost:8080/test'
name: missing
```

因为这是我们第一次接触到`ngx_lua`模块, 所以需要先简单介绍一下. ngx_lua模块将Lua语言解释器(或者LuaJIT即时编译器)嵌入到了 Nginx核心中, 从而可以让用户在Nginx核心中直接运行Lua语言编写的程序. 我们可以选择在Nginx不同的请求处理阶段插入我们的Lua代码. 这些Lua代码既可以直接内联在Nginx配置文件中, 也可以单独放置在外部.lua文件里, 然后在Nginx配置文件中引用.lua文件的路径.

回到上面这个例子, 我们在Lua代码里引用Nginx变量都是通过ngx.var这个由`ngx_lua`模块提供的Lua接口. 比如引用Nginx变量$VARIABLE时, 就在Lua代码里写作ngx.var.VARIABLE就可以了. 当Nginx变量`$arg_name`为特殊值"没找到"(或者"不合法")时, `ngx.var.arg_name`在 Lua世界中的值就是nil, 即Lua语言里的"空"(不同于Lua空字符串). 我们在Lua里输出响应体内容的时候, 则使用了ngx.say这个Lua函数, 也是`ngx_lua`模块提供的, 功能上等价于ngx_echo模块的echo配置指令.

现在, 如果我们提供空字符串取值的name参数, 则输出就和刚才不相同了:

```
$ curl 'http://localhost:8080/test?name='
name: []
```
在这种情况下, Nginx变量`$arg_name`的取值便是空字符串, 这既不是"没找到", 也不是"不合法". 因此在Lua里, ngx.var.arg_name就返回Lua空字符串(""), 和刚才的Lua nil值就完全区分开了.

这种区分在有些应用场景下非常重要, 比如有的web service接口会根据name这个URL参数是否存在来决定是否按name属性对数据集合进行过滤, 而显然提供空字符串作为name参数的值, 也会导致对数据集中取值为空串的记录进行筛选操作.

不过, 标准的$arg_XXX变量还是有一些局限, 比如我们用下面这个请求来测试刚才那个/test接口:

```
$ curl 'http://localhost:8080/test?name'
name: missing
```
此时, `$arg_name`变量仍然读出"找不到"这个特殊值, 这就明显有些违反常识. 此外, $arg_XXX变量在请求URL中有多个同名XXX参数时, 就只会返回最先出现的那个XXX参数的值, 而默默忽略掉其他实例:


```
$ curl 'http://localhost:8080/test?name=Tom&name=Jim&name=Bob'
name: [Tom]
```

要解决这些局限, 可以直接在Lua代码中使用`ngx_lua`模块提供的`ngx.req.get_uri_args`函数.

7.2.2 内建$cookie_XXX变量

与`$arg_XXX`类似, 我们在chapter 1中提到过的内建变量$cookie_XXX变量也会在名为XXX的cookie不存在时返回特殊值"没找到":

```
location /test {
    content_by_lua '
        if ngx.var.cookie_user == nil then
            ngx.say("cookie user: missing")
        else
            ngx.say("cookie user: [", ngx.var.cookie_user, "]")
        end
    ';
}
```

利用curl命令行工具的`--cookie name=value`选项可以指定`name=value`为当前请求携带的cookie(通过添加相应的Cookie请求头)下面是若干次测试结果:

```
$ curl --cookie user=agentzh 'http://localhost:8080/test'
cookie user: [agentzh]

$ curl --cookie user= 'http://localhost:8080/test'
cookie user: []

$ curl 'http://localhost:8080/test'
cookie user: missing
```

我们看到, cookie user不存在以及取值为空字符串这两种情况被很好地区分开了: 当cookie user不存在时, Lua代码中的ngx.var.cookie_user返回了期望的Lua nil值.

在Lua里访问未创建的Nginx用户变量时, 在Lua里也会得到nil值, 而不会像先前的例子那样直接让Nginx拒绝加载配置:

```conf
location /test {
    content_by_lua '
        ngx.say("$blah = ", ngx.var.blah)
    ';
}
```

这里假设我们并没有在当前的nginx.conf配置文件中创建过用户变量$blah, 然后我们在Lua代码中通过ngx.var.blah直接引用它. 上面这个配置可以顺利启动, 因为Nginx在加载配置时只会编译`content_by_lua`配置指令指定的Lua代码而不会实际执行它, 所以Nginx并不知道Lua代码里面引用了$blah这个变量. 于是我们在运行时也会得到nil值. 而ngx_lua提供的ngx.say函数会自动把Lua 的nil值格式化为字符串"nil"输出, 于是访问/test接口的结果是:

```
curl 'http://localhost:8080/test'
$blah = nil
```

这正是我们所期望的.

上面这个例子中另一个值得注意的地方是, 我们在`content_by_lua`配置指令的参数中提及了$bar符号, 但却并没有触发"变量插值"(否则 Nginx会在启动时抱怨$blah未创建). 这是因为`content_by_lua`配置指令并不支持参数的"变量插值"功能. 我们前面在(一)中提到过, 配置指令的参数是否允许"变量插值", 其实取决于该指令的实现模块.

设计返回"不合法"这一特殊值的例子是困难的. 因为我们前面已经看到, 由set指令创建的变量在未初始化时确实是"不合法", 但一旦尝试读取它们时, Nginx就会自动调用其"取处理程序", 而它们的"取处理程序"会自动返回空字符串并将之缓存住. 于是我们最终得到的是完全合法的空字符串. 下面这个使用了Lua代码的例子证明了这一点:

```conf
location /foo {
    content_by_lua '
        if ngx.var.foo == nil then
            ngx.say("$foo is nil")
        else
            ngx.say("$foo = [", ngx.var.foo, "]")
        end
    ';
}

location /bar {
    set $foo 32;
    echo "foo = [$foo]";
}
```

请求/foo接口的结果是:

```
$ curl 'http://localhost:8080/foo'
$foo = []
```

我们看到在Lua里面读取未初始化的Nginx变量$foo时得到的是空字符串.

## 7.3 其他变量类型-数组

最后值得一提的是, 虽然前面反复指出Nginx变量只有字符串这一种数据类型, 但这并不能阻止像`ngx_array_var`这样的第三方模块让Nginx变量也能存放数组类型的值. 下面就是这样的一个例子:

```conf
location /test {
    array_split "," $arg_names to=$array;
    array_map "[$array_it]" $array;
    array_join " " $array to=$res;

    echo $res;
}
```

这个例子中使用了`ngx_array_var`模块的`array_split, array_map`和array_join这三条配置指令, 其含义很接近Perl语言中的内建函数split, map和join(当然, 其他脚本语言也有类似的等价物). 我们来看看访问/test接口的结果:

```
$ curl 'http://localhost:8080/test?names=Tom,Jim,Bob
[Tom] [Jim] [Bob]
```

我们看到, 使用`ngx_array_var`模块可以很方便地处理这样具有不定个数的组成元素的输入数据, 例如此例中的namesURL参数值就是由不定个数的逗号分隔的名字所组成. 不过, 这种类型的复杂任务通过ngx_lua来做通常会更灵活而且更容易维护.

## 7.4 结语

至此，本系列教程对Nginx变量的介绍终于可以告一段落了. 我们在这个过程中接触到了许多标准的和第三方的Nginx模块, 这些模块让我们得以很轻松地构造出许多有趣的小例子, 从而可以深入探究Nginx变量的各种行为和特性. 在后续的教程中, 我们还会有很多机会与这些模块打交道.

通过前面讨论过的众多例子, 我们应当已经感受到Nginx变量在Nginx配置语言中所扮演的重要角色: 它是获取Nginx中各种信息(包括当前请求的信息)的主要途径和载体, 同时也是各个模块之间传递数据的主要媒介之一. 在后续的教程中, 我们会经常看到Nginx变量的身影, 所以现在很好地理解它们是非常重要的.

在下一个系列的教程, 即Nginx配置指令的执行顺序系列中, 我们将深入探讨Nginx配置指令的执行顺序以及请求的各个处理阶段, 因为很多Nginx用户都搞不清楚他们书写的众多配置指令之间究竟是按照何种时间顺序执行的, 也搞不懂为什么这些指令实际执行的顺序经常和配置文件里的书写顺序大相径庭.