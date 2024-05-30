# Linux-test比较判断字符串时出现too many arguments

参考文章

1. [linux bash中too many arguments问题的解决方法](https://www.jb51.net/article/42920.htm)

## 以下两种是正常情况

```log
$ abc=
$ if [ -z $abc ]; then echo empty; fi
empty
```

```log
$ abc=123
$ if [ -z $abc ]; then echo empty; fi
# 无输出
```

## too many arguments 与 binary operator expected

如果待比较字符串中包含空格或是回车啥的, 可能出现如下报错

```log
$ abc='123 456'
$ if [ -z $abc ]; then echo empty; fi
-bash: [: 123: binary operator expected
```

解决方法是, 将目标变量用双引号包裹起来.

```log
$ abc='123 456'
$ if [ -z "$abc" ]; then echo empty; fi
# 无输出
```
