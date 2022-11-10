# Linux计算命令.2.1.expr字符串操作[length index substr]

参考文章

1. [Linux下的计算器(bc、expr、dc、echo、awk)知多少？](http://blog.chinaunix.net/uid-24673811-id-1760837.html)

xpr命令字符串操作

`expr`有3个子选项可以对字符串操作

- `length string`: 返回字符串string的长度
- `index string string2`: 返回string中包含string2中任意字符第一次出现在位置(从1开始)
- `substr string pos len`: 返回string中从第pos个字符开始, 并且长度是len的字符串。

## length 求长度

```console
$ a='123abc'
$ expr length $a
6
## 空格也计入长度
$ expr length '123 abc'
7
## 不过变量形式传入的参数不能存在空格
$ a='123 abc'
$ expr length $a
expr: syntax error
```

## index 查询/索引字符串

```console
$ x='abcdefg12345'
$ y=cd
$ expr index $x $y
3
```

## substr 字符串截取

```
$ x='abcdefg12345'
$ expr substr $x 2 3
bcd
```
