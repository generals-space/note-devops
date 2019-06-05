# Shell-格式化命令行参数(二)-getopts

`getopts`是shell内置的命令， 不能直接处理长选项(如:`–prefix=/home`等). 接受两个参数，第一个参数是定义待解析选项的字符串, 第二个是一个自定义的变量. 如下

```bash
getopts 'a:bcd:' opt
```

参数1可以包含英文字符(区分大小写)和':'，每一个字符都是一个有效的选项，如果字符后面带有':'，表示这个字符后需要有自己的参数。

`getopts`会自动解析自己所在作用域内的`$*`参数列表. 如果遇到参数1中出现的带有`-`的字符, 比如`-a`, 它将会把这个字符也就是`a`赋值给参数2, 这里是`opt`变量. 这样就可以用`case...esac`语句匹配指定参数要执行的操作. 由于在参数1中`a`字符后面有一个冒号, 所以`getopts`会取出命令行中`-a`后紧接的参数并赋值给一个叫做`$OPTARG`的变量. 这个变量是`getopts`输出到脚本执行时所在的shell中的, 不需要自行定义.

然后`getopts`继续解析后面的参数, 这是一个循环过程, 所以一般搭配循环语句完成整个解析流程. 在这个过程中, `getopts`使用`$OPTIND`变量存储下一个待解析参数在命令行中的位置, 即索引值, 这个值从1开始. 同`$OPTARG`一样, 也是`getopts`输出到脚本中的.

## 1. 基础应用

```bash
#!/bin/bash
echo $*
while getopts 'a:b' opt
do
	case $opt in
	a) 
        echo 'a选项是有参数的, 这里取到它的参数为: ' $OPTARG
	    echo '此时命令行中待解析参数索引值:' $OPTIND
	    ;;
	b) 
        echo 'b选项无参数, 此时OPTARG变量的值为: ' $OPTARG        
	    echo '此时命令行中待解析参数索引值:' $OPTIND
            ;;
	?)
            echo 'error'
	    exit 1
           ;;
        esac
done
```

将其命名为`test1.sh`, 执行.

```
$ ./test1.sh -a abc -b
-a abc -b
a选项是有参数的, 这里取到它的参数为:  abc
此时命令行中待解析参数索引值: 3
b选项无参数, 此时OPTARG变量的值为:
此时命令行中待解析参数索引值: 4
```

流程分析:

`getopts`遇到`-a`选项, 由于在其参数1中有`a:`的定义, 说明a有一个参数, 于是`getopts`取得'abc'并将其赋值给`$OPTARG`, 此时`$OPTIND`指向`-b`的位置, 即为3.

取得`-b`后将`$OPTIND`指向其后的参数位置(虽然没有), 为4.

尝试执行`./test1.sh -a abc -b 123`, 会发现`getopts`并未取得123这个值, 因为`$OPTARG`依然为空. 这是因为`getopts`并未尝试去获取`-b`的参数, 而向后移动发现`123`不在其参数1中的列表里, 解析终止.


## 2. 解析终止

`getopts`解析终止的条件:

1. 无参选项后接了一个参数

2. 出现一个不在参数1中的选项(可能是非法选项或多余参数)

仍然使用上述`test1.sh`为例.

**验证第1点**

```
$ ./test1.sh -b 123 -a abc
-b 123 -a abc
b选项无参数, 此时OPTARG变量的值为: 
此时命令行中待解析参数索引值: 2
```

`getopts`只会取得b选项, 到123处终止, 无法得到`-a`选项及其参数值.

**验证第2点**

```
$ ./test1.sh -a abc -c -b 
-a abc -c -b
a选项是有参数的, 这里取到它的参数为:  abc
此时命令行中待解析参数索引值: 3
./test1.sh: illegal option -- c
error

$ ./test1.sh -a abc 123 -b 
-a abc 123 -b
a选项是有参数的, 这里取到它的参数为:  abc
此时命令行中待解析参数索引值: 3
```

注意, 上面两种种是不同的情况, **非法选项会报错, 多余参数则直接停止**.

所以, `getopts`使用的注意点就是这里: 如果想要让`getopts`处理参数中的一部分, 脚本的其他内容处理剩余的部分, 则对`getopts`合法的部分与非法部分不能混杂, 必须严格分离.

```
$ 
```

## 3. 冒号 - 忽略错误

在`getopts`的参数1中将`:`作为第1个字符, 可以不显示非法参数的警告.

以上述`test1.sh`为例

```
$ ./test1.sh -a abc -c
-a abc -c
a选项是有参数的, 这里取到它的参数为:  abc
此时命令行中待解析参数索引值: 3
./test1.sh: illegal option -- c
error
```

在其基础上修改为

```bash
#!/bin/bash
echo $*
## 参数1开始处添加一个冒号, 忽略错误
while getopts ':a:b' opt
do
	case $opt in
	a) 
        echo 'a选项是有参数的, 这里取到它的参数为: ' $OPTARG
	    echo '此时命令行中待解析参数索引值:' $OPTIND
	    ;;
	b) 
        echo 'b选项无参数, 此时OPTARG变量的值为: ' $OPTARG        
	    echo '此时命令行中待解析参数索引值:' $OPTIND
        ;;
	?)
        echo 'error'
		## 移除自动退出操作
	    ## exit 1
        ;;
        esac
done
echo '解析完成'
```

再次执行

```
 ./test1.sh -a abc -c
-a abc -c
a选项是有参数的, 这里取到它的参数为:  abc
此时命令行中待解析参数索引值: 3
error
解析完成
```

如果在`?)..;;`的case语句中不跳过错误提示, 则不会再出现`illegal option`这样的输出.

## 4. 多参数

`getopts`的参数1中字符顺序没有严格限制. 比如使脚本接受`-a`和`-c`两个可以带参数的选项, 下面两种写法都是正确的.

```bash
getopts ':a:bc:' opt
getopts ':a:c:b' opt
```
