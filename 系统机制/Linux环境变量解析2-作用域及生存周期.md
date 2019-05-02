Linux环境变量解析2-变量作用域及生命周期

参考文章

[shell浅谈之九子shell与进程处理](http://blog.csdn.net/taiyang1987912/article/details/39529291)

[实例解析shell子进程（subshell )](http://blog.csdn.net/sosodream/article/details/5683515)

[env命令](http://man.linuxde.net/env)

[set命令](http://man.linuxde.net/set)

1. abc=123

2. abc=123 && set -a abc

3. export abc=123

4. declare abc=123

5. declare -x abc=123

6. env abc=123

其中, 1和4的效果相同, 2,3和5的效果相同.

1,4只是在当前bash进程中设置变量, 无法影响到其他bash进程, 无论是子bash进程, 父bash进程还是同级的新创建的bash进程. 这里称这种变量为**普通变量**, 也被称为**bash变量**.

通过2,3,5方式创建的变量, 在同一用户, 并且属于当前bash进程的子级进程中有效. 即通过当前bash shell以这几种方法创建的变量, 可以传递给所有在当前bash, 以同一用户身份启动的进程中. 但对于父级bash进程和同级bash进程无效. 这种变量称为**用户变量**.

## 变量作用域分析

### bash变量

#### 示例1

当前bash中定义的普通变量, 无法传递到子bash进程.

```
$ cat test.sh
#!/bin/bash
echo 'begin'
echo $abc
echo 'end'
$ abc=123
$ echo $abc
123
$ ./test.sh
begin

end
```

#### 示例2

当前bash中定义的普通变量, 也无法影响到父级bash进程.

```
$ cat test.sh 
#!/bin/bash
def=456
echo $def
$ ./test.sh 
456
$ echo $def

```

#### 示例3

但是这种普通变量却可以传递到subshell进程中, 不过subshell中定义的普通变量影响到父shell.

```
$ abc=123
$ (echo $abc)
123
$ (abc=789; echo $abc)
789
$ echo $abc
123
```

------

这里需要注意的是, bash进程与shell进程不是一回事. 两者的区别可以通过`$$`特殊变量查看, 这表示当前bash进程的进程号, 或者也可以通过`$BASH_SUBSHELL`变量查看, 它表示子shell的层级数.

```
$ echo $$; echo $BASH_SUBSHELL
3299
0
$ (echo $$; echo $BASH_SUBSHELL)
3299
1
```

可以看到, 这种通过小括号创建的subshell, 与原shell同用同一个bash进程, 只是shell层级会增加.   subshell是允许嵌套调用的，可以在函数或圆括号结构内再次调用圆括号结构创建subshell.

而执行脚本时, 由于第一行`#!/bin/bash`这一句的存在, shell脚本都是新建bash进程然后再执行其中的命令.

```
$ cat test.sh
#!/bin/bash
echo $$; echo $BASH_SUBSHELL
$ ./test.sh
5990
0
```

这两者的区别应该用更深层的涵义, 目前先保留这个问题<???>.

### 用户变量分析

用户级变量与bash级变量最大的不同, 应该就是前者可以延父子关系上下传递而后者不可以.

通过2,3,5中任意一种方式可以创建用户级变量.

```
$ cat test.sh 
#!/bin/bash
echo 'begin'
echo $abc
echo 'end'
$ export abc=789
$ ./test.sh 
begin
789
end
```

## 不同级别变量操作

### 1. set命令

set命令作用主要是显示系统中已经存在的shell变量, 或者用于更改shell特性，符号"+"和"-"的作用分别是打开和关闭指定的模式. set命令本身不能够定义新的shell变量.

在不添加任何选项的时候, 显示当前会话中所有合法的变量，包括用户级变量. 

### 2. env命令

不接任何参数的情况下, 显示当前的用户级别变量. 

`env abc=123`可以将`abc`设置为用户级别变量, 当前bash进程及其子进程中有效.

`env -u abc`可以从当前用户级环境变量中删除变量`abc`.

### 3. export命令

在不接任何参数时, 显示当前导出成用户变量的bash变量, 这些变量原本是bash级别变量, 之后被提升至用户级别.

它可以接一个参数, 类似于`export abc=123`或是`abc=123 && export abc`, 将普通变量`abc`提升到用户变量级别, 之后通过此shell启动的命令, 都可以读取到这个变量, 它的生命周期仅限于当前shell结束之前.

不过, `export`的输出都很相似, 如下

```
$ export
declare -x CLASSPATH=".:/usr/local/jdk1.8.0_101/lib/dt.jar:/usr/local/jdk1.8.0_101/lib/tools.jar"
declare -x HISTCONTROL="ignoredups"
declare -x HISTSIZE="1000"
...
```

所有被提升至用户级别的变量, 实际上都是通过`declare`命令为bash级变量赋予了`-x`属性, 暂时不知道这两个命令之间有何内在的关联<???>.

### 4. declare命令

在不接任何参数时, 可以显示当前会话中所有合法变量...貌似与set的输出相同, 不仅包括普通变量, 还有用户级别变量.

~~`declare abc=123`可以将变量`abc`声明为一个普通变量.~~ 这句话被注释掉了, 但也不能完全说是错误的, 在CentOS7系统中`declare abc=123`默认为附带`-x`属性, 即将其声明为用户级别变量, 所以如果不带任何属性, `abc`也本应该只是一个普通变量而已.