# Shell-各种括号.3.2.大括号-字符串截取

几种模式匹配替换结构:

- `${var%pattern}`
- `${var%%pattern}`
- `${var#pattern}`
- `${var##pattern}`

> `pattern`一般是显式字符串, 不能是变量???

这四种模式中都不会改变`var`的值, 如要修改, 需要重新赋值. 

结构中的`pattern`支持通配符, `*`表示零个或多个任意字符, `?`表示零个或一个任意字符, `[...]`表示匹配中括号里面的字符, `[!...]`表示不匹配中括号里面的字符.

其中, 只有在`pattern`中使用了`*`通配符时, `%`和`%%`, `#`和`##`才有区别. 

## 1. `${var%pattern}`

如果`var`变量以指定的模式`pattern`结尾, 就从命令行把var中的内容移除右边最短的匹配字符串, 否则直接输出原`var`的值.

```bash
var=testcase
echo $var               ## testcase
## 从最右边删除最短匹配
echo ${var%s*e}         ## testca
## 未匹配
echo ${var%xxx}         ## testcase
```

## 2. `${var%%pattern}`

如果`var`变量以指定的模式`pattern`结尾, 就从命令行把var中的内容移除右边最长的匹配字符串(即贪心匹配), 否则直接输出原`var`的值.

```bash
var=testcase
echo $var               ## testcase
## 从最右边删除最长匹配
echo ${var%%s*e}        ## te
## 未匹配
echo ${var%%xxx}        ## testcase
```

## 3. `${var#pattern}`

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

## 4. `${var##pattern}`

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

## 5. 包含[]的pattern

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
