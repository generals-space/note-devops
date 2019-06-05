# Shell脚本元素-各种括号(一)-大括号

参考文章

[玩转Bash变量](https://segmentfault.com/a/1190000002539169)

## 3. 大括号(花括号)

### 3.1 单大括号(没有双的)

#### 3.1.1 序列化字符串生成

1. 两个点号`.`生成顺序字符串

2. 逗号`,`分隔, 不可以有空格

```
$ touch test{1..4}.txt
$ ls 
test1.txt  test2.txt  test3.txt  test4.txt

$ touch {test{1..4},testab}.txt
$ ls 
test1.txt  test2.txt  test3.txt  test4.txt  testab.txt
```

#### 3.1.2 代码块

代码块，又被称为内部组，这个结构事实上创建了一个匿名函数 。与小括号中的命令不同，大括号内的命令不会新开一个子shell运行，即脚本余下部分仍可使用括号内变量。括号内的命令间用分号隔开，**最后一个也必须有分号**。**{}中的第一个命令和左括号之间必须要有一个空格**。

```
$ { a=1; ((a++));}; echo $a;
```

#### 3.1.3 逻辑匹配/替换

作用类似于类C语言中的三目运算符.

|变量设定方式	       |var未定义	            |var 为空字串	        |var 已赋值为非空字串|
|:-:|:-:|:-:|:-:|
|str=\${var-expr}	|str=expr	           |str=	               |str=\$var         |
|str=\${var:-expr}	|str=expr	           |str=expr	           |str=\$var         |
|str=\${var+expr}	|str=	               |str=expr	           |str=expr          |
|str=\${var:+expr}	|str=	               |str=	               |str=expr          |
|str=\${var?expr}	|expr将输出至stderr	    |str=	                |str=\$var         |
|str=\${var:?expr}	|expr将输出至stderr	    |expr将输出至stderr	     |str=\$var         |
|str=\${var=expr}	|str=expr	           |str=	               |str=\$var         |
|str=\${var:=expr}	|str=expr	           |str=expr	           |str=\$var         |

示例

**A. `${var:-string}`和`${var:=string}`**

若变量`var`为空，则用在命令行中用string来替换`${var:-string}`，否则用变量var的值来替换`${var:-string}`；对于`${var:=string}`的替换规则和${var:-string}是一样的，所不同之处是`${var:=string}`若var为空时，用string替换${var:=string}的同时，把string赋给变量var： ${var:=string}很常用的一种用法是，判断某个变量是否赋值，没有的话则给它赋上一个默认值。

```
## abc为空
$ abc=''
$ echo ${abc:-123}
123
$ echo $abc

$ abc=''
$ echo ${abc:=123}
123
$ echo $abc
123

## abc不为空
$ abc='321'
$ echo ${abc:-123}
321
```

B. `${var:+string}`的替换规则和上面的相反，即只有当var不是空的时候才替换成string，若var为空时则不替换或者说是替换成变量 var的值，即空值。(因为变量var此时为空，所以这两种说法是等价的) 

```
$ abc=''
$ echo ${abc:+321}

$ abc='123'
$ echo ${abc:+321}
321
```

C. `${var:?string}`替换规则为：若变量var不为空，则用变量var的值来替换`${var:?string}`；若变量var为空，则把string输出到标准错误中，并从脚本中退出。我们可利用此特性来检查是否设置了变量的值。

```
$ echo $abc
123
$ echo ${abc:?hehe}
123
$ abc=''
$ echo ${abc:?hehe}
-bash: abc: hehe
```

D. 

> PS：在上面这五种替换结构中string不一定是常值的，可用另外一个变量的值或是一种命令的输出。


#### 3.1.4 模式匹配/替换

几种模式匹配替换结构:

- `${var%pattern}`

- `${var%%pattern}`

- `${var#pattern}`

- `${var##pattern}`

**A. ${var%pattern}**

这种模式时，shell在var中查找，看它是否以指定的模式pattern结尾，如果是，就从命令行把var中的内容去掉右边最短的匹配模式.

**B. ${var%%pattern}**

这种模式时，shell在var中查找，看它是否以指定的模式pattern结尾，如果是，就从命令行把var中的内容去掉右边最长的匹配模式, 就是贪心匹配.

**C. ${var#pattern}**

这种模式时，shell在var中查找，看它是否以指定的模式pattern开始，如果是，就从命令行把var中的内容去掉左边最短的匹配模式

**D. ${var##pattern}**

这种模式时，shell在var中查找，看它是否以指定的模式pattern结尾，如果是，就从命令行把var中的内容去掉右边最长的匹配模式, 也是贪心匹配.
    
这四种模式中都不会改变var的值, 如要修改, 需要重新赋值. 其中，只有在pattern中使用了`*`通配符时，`%`和`%%`，`#`和`##`才有区别。结构中的`pattern`支持通配符，`*`表示零个或多个任意字符，`?`表示零个或一个任意字符，`[...]`表示匹配中括号里面的字符，`[!...]`表示不匹配中括号里面的字符.

小例子

```
$ var=testcase
$ echo $var
testcase
## 从最右边删除最短匹配
$ echo ${var%s*e}
testca
## 从最右边删除最长匹配
$ echo ${var%%s*e}
te
## 原变量没有改变
$ echo $var 
testcase
```

```
$ var=testcase
## 从最左边删除最短匹配
$ echo ${var#?e}
stcase
## 从最左边删除最短匹配
$ echo ${var#*e}  
stcase
## 从最左边删除最长匹配，在本例中会删除所有
$ echo ${var##*e}

## 从最左边删除最长匹配
$ echo ${var##*s}
e
## 删除test
$ echo ${var#test}
case
## 没有匹配
$ echo ${var#tests}
testcase
```

```
$ var=testcase
## 从左边删除testc或test1字符串
$ echo ${var#test[c1]}
ase
## 从左边删除test1字符串, 当然, 是没有的
$ echo ${var#test[1]}
testcase
## 从左边删除一个test?的字符串, 只要不是test1就行
$ echo ${var#test[!1]}
ase
## 可以混着用哦
$ echo ${var#test[!1][ab]}
se
```

#### 3.1.5 查找替换


- `${var/str/newstr}`

- `${var//str/newstr}`

就是精确匹配后替换啦.

前者中, 变量`var`包含`str`字符串, 则只有第一个`str`会被替换成`newstr`;

后者中, 变量`var`包含`str`字符串, 则全部的`str`都会被替换成`newstr`;

同样, 这两种方法也不会修改原变量的值, 并且也可以使用通配符, 不过只能使用`?`与`*`.

#### 3.1.6 大小写转换

```
$ HI=HellO

$ echo "$HI" 
HellO
$ echo ${HI^} 
HellO
$ echo ${HI^^} 
HELLO
$ echo ${HI,} 
hellO
$ echo ${HI,,} 
hello
$ echo ${HI~} 
hellO
$ echo ${HI~~} 
hELLo
```

`^`大写，`,`小写， `~`大小写切换. 重复一次只修改首字母，重复两次则应用于所有字母。

混着用会怎样？

```
$ echo ${HI^,^} 
HellO
```

看来是不行的×_×