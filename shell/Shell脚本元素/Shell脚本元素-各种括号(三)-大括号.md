# Shell脚本元素-各种括号(一)-大括号

参考文章

1. [玩转Bash变量](https://segmentfault.com/a/1190000002539169)
2. [菜鸟学Linux - 变量基本规则](https://www.cnblogs.com/jonathanlin/p/4063205.html)
    - 逻辑匹配/替换表格
3. [shell的字符串截取](https://my.oschina.net/u/3314358/blog/2051268)
    - 字符串切片: 固定位置截取(正向与反向)
4. [Bash Shell字符串操作小结](https://my.oschina.net/aiguozhe/blog/41557)
    - 字符串切片: 反向截取示例 `${str:(-4):3}`

大括号只有单层的, 没有`{{expression}}`的用法.

## 1. 序列化字符串生成

1. 两个点号`.`生成顺序字符串
2. 逗号`,`分隔, 不可以有空格

```bash
touch test{1..4}.txt
ls                      ## test1.txt  test2.txt  test3.txt  test4.txt
```

```bash
touch {test{1..4},testab}.txt
ls                      ## test1.txt  test2.txt  test3.txt  test4.txt  testab.txt
```

## 2. 代码块(匿名函数)

代码块, 又被称为内部组, 这个结构事实上创建了一个匿名函数. 

与小括号中的命令不同, 大括号内的命令不会新开一个子shell运行, 即脚本余下部分仍可使用括号内变量. 

括号内的命令间用分号隔开, **最后一个也必须有分号**. **{}中的第一个命令和左括号之间必须要有一个空格**. 

```bash
{ a=1; ((a++));}; echo $a; ## 2
```

## 3. 逻辑匹配/替换

作用类似于类C语言中的三目运算符, 按照条件`cond`取值的同而不同.

| 变量设定方式       | 当`cond`变量未定义时`str` | 当`cond`变量为空字符串时`str` | 当`cond`变量为非空字符串 |
| :----------------- | :------------------------ | :---------------------------- | :----------------------- |
| `str=${cond-var}`  | str=var                   | str=                          | str=cond                 |
| `str=${cond:-var}` | str=var                   | str=var                       | str=cond                 |
| `str=${cond+var}`  | str=                      | str=var                       | str=var                  |
| `str=${cond:+var}` | str=                      | str=                          | str=var                  |
| `str=${cond=var}`  | str=var; cond=var         | str=   ; cond不变(仍为空)     | str=cond; cond不变       |
| `str=${cond:=var}` | str=var; cond=var         | str=var; cond=var             | str=cond; cond不变       |
| `str=${cond?var}`  | var将输出至stderr         | str=                          | str=cond                 |
| `str=${cond:?var}` | var将输出至stderr         | var将输出至stderr             | str=cond                 |

### 3.1 `${cond-var}`与`${cond:-var}`

新开终端, 重新声明变量

```bash
var=789
## 此时cond不存在(不是为空)
echo ${cond-$var} ## 789
cond=
echo ${cond-$var} ## (空)
cond=123
echo ${cond-$var} ## 123
```

```bash
var=789
## 此时cond不存在(不是为空)
echo ${cond:-$var} ## 789
cond=
echo ${cond:-$var} ## 789    这里与上面不同
cond=123
echo ${cond:-$var} ## 123
```

主要规则: `cond`为空时取`var`的值, 否则取`cond`的值. 但是`cond`不存在与取空值, 结果是不同的, 需要注意.

### 3.2 `${cond+var}`与`${cond:+var}`

```bash
var=789
## 此时cond不存在(不是为空)
echo ${cond+$var} ## (空)
cond=
echo ${cond+$var} ## 789
cond=123
echo ${cond+$var} ## 789
```

```bash
var=789
## 此时cond不存在(不是为空)
echo ${cond:+$var} ## (空)
cond=
echo ${cond:+$var} ## (空)    这里与上面不同
cond=123
echo ${cond:+$var} ## 789
```

主要规则: `cond`为空时取空值, 否则取`var`的值. 几乎与上面的相反, 但相同的, 在`cond`不存在与取空值时的结果也不一样.

### 3.3 `${cond=var}`与`${cond:=var}`

```bash
var=789
## 此时cond不存在(不是为空)
echo ${cond=$var} ## 789
echo $cond        ## 789 此时cond被赋予了值
cond=
echo ${cond=$var} ## (空)
echo $cond        ## (空)
cond=123
echo ${cond=$var} ## 123
echo $cond        ## 123
```

```bash
var=789
## 此时cond不存在(不是为空)
echo ${cond:=$var} ## 789
echo $cond         ## 789 此时cond被赋予了值
cond=
echo ${cond:=$var} ## 789
echo $cond         ## 789
cond=123
echo ${cond:=$var} ## 123
echo $cond         ## 123
```

基本规则还是, 在`cond`不存在/空的时候, 取`var`值, 否则取`cond`的值.

这种模式的匹配与替换, 不只会因为`cond`的取值影响最终结果, 还会影响到`cond`变量本身.

### 3.4 `${cond?var}`与`${cond:?var}`

```bash
var=789
## 此时cond不存在(不是为空)
echo ${cond?$var} ## 报错 -bash: cond: 789
cond=
echo ${cond?$var} ## (空)
cond=123
echo ${cond?$var} ## 123
```

```bash
var=789
## 此时cond不存在(不是为空)
echo ${cond:?$var} ## 报错 -bash: cond: 789
cond=
echo ${cond:?$var} ## 报错 -bash: cond: 789
cond=123
echo ${cond:?$var} ## 123
```

## 4. 字符串截取(移除)

几种模式匹配替换结构:

- `${var%pattern}`
- `${var%%pattern}`
- `${var#pattern}`
- `${var##pattern}`

> `pattern`一般是显式字符串, 不能是变量???

这四种模式中都不会改变`var`的值, 如要修改, 需要重新赋值. 

结构中的`pattern`支持通配符, `*`表示零个或多个任意字符, `?`表示零个或一个任意字符, `[...]`表示匹配中括号里面的字符, `[!...]`表示不匹配中括号里面的字符.

其中, 只有在`pattern`中使用了`*`通配符时, `%`和`%%`, `#`和`##`才有区别. 

### 4.1 `${var%pattern}`

如果`var`变量以指定的模式`pattern`结尾, 就从命令行把var中的内容移除右边最短的匹配字符串, 否则直接输出原`var`的值.

```bash
var=testcase
echo $var               ## testcase
## 从最右边删除最短匹配
echo ${var%s*e}         ## testca
## 未匹配
echo ${var%xxx}         ## testcase
```

### 4.2 `${var%%pattern}`

如果`var`变量以指定的模式`pattern`结尾, 就从命令行把var中的内容移除右边最长的匹配字符串(即贪心匹配), 否则直接输出原`var`的值.

```bash
var=testcase
echo $var               ## testcase
## 从最右边删除最长匹配
echo ${var%%s*e}        ## te
## 未匹配
echo ${var%%xxx}        ## testcase
```

### 4.3 `${var#pattern}`

如果`var`变量以指定的模式`pattern`开始, 就从命令行把var中的内容移除左边最短的匹配字符串, 否则直接输出原`var`的值.

```bash
var=testcase
echo $var               ## testcase
## 从最左边删除最短匹配
echo ${var#?e}          ## stcase
## 从最左边删除最短匹配
echo ${var#*e}          ## stcase
## 未匹配
echo ${var#xxx}         ## testcase
```

### 4.4 `${var##pattern}`

如果`var`变量以指定的模式`pattern`开始, 就从命令行把var中的内容移除左边最长的匹配字符串(即贪心匹配), 否则直接输出原`var`的值.

```bash
var=testcase
## 从最左边删除最长匹配
echo ${var##*e}   ## 这里会删除所有, 输出为空
## 从最左边删除最长匹配
echo ${var##*s}   ## e
## 删除test
echo ${var#test}  ## case
## 未匹配
echo ${var#tests} ## testcase
```

### 4.5 包含[]的pattern

```bash
var=testcase
## 从左边删除testc或test1字符串
echo ${var#test[c1]}                      ## ase
## 从左边删除test1字符串, 当然, 是没有的
echo ${var#test[1]}                       ## testcase
## 从左边删除一个test?的字符串, 只要不是test1就行
echo ${var#test[!1]}                      ## ase
## 可以混着用哦
echo ${var#test[!1][ab]}                  ## se
```

## 5. 切片实现: 固定位置截取

`${varible:start:len}`

截取变量`varible`从位置`start`开始长度为`len`的子串, 第一个字符的位置起始为0.

```bash
var=testcase
echo ${var:0:4} ## test
echo ${var:4:4} ## case
echo ${var:4} ## case 截取到末尾
```

```bash
var=testcase
echo ${var:-4:4}    ## testcase
echo ${var:(-4):4}  ## case
echo ${var:0-4:4}   ## case
```

**注意点**

1. 反向截取时`start`格式为`0-n`, `0-`不可省略, 直接写一个负值, 操作无效.
2. `start`可以小于0, 但没有任何作用, 不能实现倒数截取的功能. 当`start<0`时, 截取功能无效, `len`无论取何值都会输出整个字符串.
    - `echo ${var:-1:4}` 输出 `testcase`
    - `echo ${var:-1:-4}` 输出 `testcase`
3. `start<0`时, `len`可取负值(虽然没什么用), 但是`start>=0`时, `len`只能>=0, 否则会报错.
    - `echo ${var:0:-1}` 报错 `-bash: -1: substring expression < 0`

## 6. 查找替换

就是精确匹配后替换啦.

- `${var/str/newstr}`: 变量`var`包含`str`字符串, 则只有第一个`str`会被替换成`newstr`;
- `${var//str/newstr}`: 变量`var`包含`str`字符串, 则全部的`str`都会被替换成`newstr`;

```bash
var='hello world'
echo ${var/o/i}     ## helli world
echo ${var//o/i}    ## helli wirld
```

同样, 这两种方法也不会修改原变量`var`的值, 并且也可以使用通配符, 不过只能使用`?`与`*`.

```bash
var='hello world'
echo ${var/?o/ii}       ## helii world
echo ${var//?o/ii}      ## helii iirld
```

## 7. 大小写转换

```bash
HI=HellO

echo "$HI"        ## HellO
echo ${HI^}       ## HellO
echo ${HI^^}      ## HELLO
echo ${HI,}       ## hellO
echo ${HI,,}      ## hello
echo ${HI~}       ## hellO
echo ${HI~~}      ## hELLo
```

`^`大写, `,`小写, `~`大小写切换. 重复一次只修改首字母, 重复两次则应用于所有字母. 

混着用会怎样？

```bash
echo ${HI^,^}   ## HellO
```

看来是不行的×_×
