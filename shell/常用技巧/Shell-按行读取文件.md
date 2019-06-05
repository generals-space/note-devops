# Shell-按行读取文件

参考文章

[shell按行读取文件的3种方法](http://www.jb51.net/article/48830.htm)

## 1. 第一种

```bash
#!/bin/bash
while read line
do
    echo $line
done < filename(待读取的文件)
```

## 2. 第二种

```bash
#!/bin/bash
cat filename(待读取的文件) | while read line
do
    echo $line
done
```

## 3. 第三种

```bash
for line in `cat filename(待读取的文件)`
do
    echo $line
done
```

------

上面3种方法是网上出现比较多的, 第1种与第2种原理相似, 效果也相同; 第3种则有些区别. 例如

```shell
## file文件中的内容如下
$ cat file
1111
2222
3333 4444 555

## while read方式读取
$ cat file | while read line; do echo $line; done
1111
2222
3333 4444 555
## for..in..方式读取
$ for line in $(<file); do echo $line; done
1111
2222
3333
4444
555
```

可以看到, 第3种`for..in..`方法其实是将空格与换行符都作为了分隔符, 所以得到的不是我们通常想要的一行的内容. 

## 4. 我的扩展

但是`while read..`方法也有一些隐含的问题. 由于`read`是种标准输入中读取数据, 如果循环体内部有可能从标准输入中获取输入值时会出现干扰, 比如`ssh 用户名@IP地址 '待执行命令'`这种情况, ssh的`-n`选项就是为了解决这个问题, 但并不能完全搞定. 而且被读取文件最后一行需要存在一个空行, 否则最后一行的数据没办法获取到.

我们使用`sed`命令逐行获取内容.

```bash
#!/bin/bash
## line_sum, 总行数; line_num, 行号(从1开始, 因为sed按行获取内容时, 索引是从1开始计数而不是从0开始)
filename=文件名
line_sum=$(cat $filename | wc -l)
for ((line_num = 1; line_num <= $line_sum; line_num ++))
do
    line=$(sed -n "${line_num}p" $filename)
    echo $line
done
```

缺点是每次获取都会读取文件, 而不像`while read`方式先把整个文件内部读入. 从高级语言角度来看, 缓冲区方式的读写效率会高一些...貌似.

------

引申, 行号按指定步长增加

```
for ((line_num = 1; line_num <= $line_sum; line_num=$((${line_num}+2))))
```

这里用到了`$(())`运算符做简单运算, 每次增加2.