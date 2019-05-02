# time(新)获取命令执行时间

bash内置了一个`time`命令, 功能比较少, `/usr/bin/time`是具有更强大功能的另一个命令, 可以有格式化输出. 例如`/usr/bin/time -f %e 待测命令`

time的默认输出是在`stderr`中的, 有时用`var=$(time [option] command [arguments])`进行变量赋值时会得到空值.

使用下面的命令可以解决这个问题.

```
$ var=$(/usr/bin/time -f %e curl -s -o baidu www.baidu.com 2>&1)
$ echo $var ## 0.31
```

curl的`-s`选项必不可少, 不然curl的输出会扰乱变量var的赋直. 另外, 注意`$()`的包裹范围, 把`2>&1`也圈进去了.
