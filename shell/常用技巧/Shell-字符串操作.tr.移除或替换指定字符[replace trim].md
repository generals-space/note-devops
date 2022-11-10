# Shell-字符串操作.tr.移除或替换指定字符

参考文章

1. [remove control characters from string using TR](https://stackoverflow.com/questions/63352649/remove-control-characters-from-string-using-tr)

`tr`可以从标准输入中得到的字符串中, 移除某个字符, 或是将目标字符替换成另一字符.

## 替换

将"1"替换成"2"

```console
$ echo 123 | tr '1' '2'
223
```

注意: `tr`操作只针对单个字符, 所以不能批量替换, 只能用多级管道

```console
$ echo 123 | tr '1' '2' | tr '3' '2'
222
```

## 删除

从字符串中移除指定字符, 不能用`tr '1' ''`这种形式, 这是错误的.

```console
$ echo 123 | tr '1' ''
tr: when not truncating set1, string2 must be non-empty
```

正确的做法是, 使用`-d`选项.

```console
$ echo 123 | tr -d '1'
23
```

`-d`选项是支持多个字符的.

```console
$ echo 123 | tr -d '12'
3
```

------

使用`tr`命令, 也可以操作不可见字符, 如换行`\n`(以及`\r`), 这样可以灵活的将目标字符串从单行变成多行, 或是多行变成单行.

```console
$ echo '1 2 3' | tr ' ' '\n'
1
2
3
```

在某种程度上, 可以实现`trim`的效果.
