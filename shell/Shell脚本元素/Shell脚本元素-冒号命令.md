# Shell脚本元素-冒号命令

参考文章

1. [shell中的冒号“：”--个人整理总结版-注意与makfle中:的区别](http://blog.csdn.net/honghuzhilangzixin/article/details/7073312/)

> 本文不讨论`:=`的情况, 也不讨论`PATH`环境变量中的`:`分隔符.

`man :`可以在man手册中查看到冒号在bash中是一个内置命令, 它的解释如下:

```
: [arguments]
        No effect; the command does nothing beyond expanding arguments and performing any specified redirections.  A zero exit code is returned.
```

...没看懂

## 1. 用法

### 1.1 占位符

比如在编写脚本的过程中，某些语法结构需要多个部分组成，但开始阶段并没有想好或完成相应的代码，这时就可以用`:`来做占位符，否则执行时就会报错。

```bash
if [ "today" == "2011-08-29" ]; then  
    :  
else  
    :  
fi
```

没错, 就像python中的`pass`.

### 1.2 单行注释

类似于shell脚本中的`#`.

```
$ : abc=1234 
$ echo $abc 
    # 赋值语句没执行
```

...md, 瞎折腾. 好好的干嘛不用`#`.

------

OK, 我想到一个可能性, 语法高亮... 

我们知道, 普通注释都会把本行变成一种被'遗弃'的颜色, 但是冒号注释不会, `salt-minion`的启动脚本中有这么用的.

![](https://gitee.com/generals-space/gitimg/raw/master/e6dec0cb18075bb1567512c3abbed0f7.png)

这么些注释我哪分得清, 丧心病狂啊!!!

### 1.3 清空文件

有点像`echo '' > file`, 不过更加简洁.

`: > file`

```
$ echo 'xxx' > logfile
$ cat logfile 
xxx
$ : > logfile 
$ cat logfile 
    # 这里会得到空
```