# Shell-各种括号.3.1.大括号-字符串三目判断

大括号用于逻辑匹配/替换, 作用类似于类C语言中的三目运算符, 按照条件`cond`取值的同而不同.

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

## 1. `${cond-var}`与`${cond:-var}`

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

## 2. `${cond+var}`与`${cond:+var}`

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

## 3. `${cond=var}`与`${cond:=var}`

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

## 4. `${cond?var}`与`${cond:?var}`

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
