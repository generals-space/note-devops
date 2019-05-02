# Linux命令-find

参考文章

1. [Find命令搭配atime/ctime/mtime时的日期写法](http://golehuang.blog.51cto.com/7499/1108124/)

2. [每天一个linux命令（20）：find命令之exec](http://www.cnblogs.com/peida/archive/2012/11/14/2769248.html)

## 1. 基础用法-按名称查找

```
## find 目标路径 -name '目标名称'
$ find /etc/ -name 'yum.conf'
```

可以使用`*`与`?`通配符匹配文件名.

## 2. 按照时间查找

语法

```
find 目标路径 {-atime|-ctime|-mtime|-amin|-cmin|-mmin} [-|+]num
```

使用`atime/ctime/mtime`时, 后面的num值将被视为天数, 即单位为天; 使用`amin/cmin/mmin`时, 后面的num值将被视为分钟数, 也就是说这被当作num的单位. (关于a, c, m这三种时间的含义需要自行了解).

后面的`[-|+]num`, 表示计时的时间段. `-num`表示**从这个时间开始**, `+num`表示**到这个时间为止**, 不带`+`或`-`的话将被看作是限制完全符合这个时间点. 

解释一下, 例如, 

`-mtime -3`, 可以表示查找**3天内**被修改过的文件(3天前不包括第3天, 被修改过的文件不会出现);

`-mtime +3`表示查找修改时间**大于3天**的文件;

`-mtime 3`则表示查找在3天前(当天内)被修改过的文件;

实践是检验真理的唯一标准...

```
## 通过date设置日期, 从01-01到01-05, 每天touch一个文件
$ date -s '2016/01/01 12:00:00'
Fri Jan  1 12:00:00 CST 2016
$ touch file1
$ date -s '2016/01/02 12:00:00'
Sat Jan  2 12:00:00 CST 2016
$ touch file2
$ date -s '2016/01/03 12:00:00'
Sun Jan  3 12:00:00 CST 2016
$ touch file3
$ date -s '2016/01/04 12:00:00'
Mon Jan  4 12:00:00 CST 2016
$ touch file4
$ date -s '2016/01/05 12:00:00'
Tue Jan  5 12:00:00 CST 2016
$ touch file5
$ date -s '2016/01/06 12:00:00'
Wed Jan  6 12:00:00 CST 2016
## 可以使用stat命令查看这些文件的3种时间属性, 这里省略结果
$ stat ./*
...
```

然后使用find命令分别寻找ctime小于, 等于, 大于3的文件, 注意: "今天"是01-06, 上述手段创建的文件, 3种时间属性相同.

```
$ find ./ -ctime +3
./file1
./file2
$ find ./ -ctime 3
./file3
$ find ./ -ctime -3
./
./file4
./file5
$ find ./ -ctime 0
$ find ./ -ctime 1
./
./file5
```

可以看出`-ctime 0`表示当天修改过的文件, 所以`{-atime|-ctime|-mtime|-amin|-cmin|-mmin}`子选项后面的参数值, 是从0开始计算的.


## 3. exec选项执行命令

我们使用`find`, 很多时候并不是单单只是想看看有哪些文件而已, 比如删掉查出来的很早的文件, 或是查看这些文件的详细信息. 这个时候可以使用`find`的`exec`参数.

`-exec`参数后面跟的是普通的bash命令，它的终止是以`;`为结束标志的，所以命令后面的分号是不可缺少的，考虑到各个系统中分号会有不同的意义，所以前面加反斜杠`\`, 而`{}`代表查找出的文件。

```
## 显示详细信息
find ./ -mtime +1000 -exec ls -l {} \;
## 或者删掉它们
find ./ -mtime +1000 -exec rm {} \;
## 删掉它们之前还可以备份, 这种可以字符串合并太爽了
find ./ -mtime +1000 -exec mv {} /tmp/{}.bak \;
```

> 注意: find的`exec`所表示的子命令, 在每find到一个文件/目录就会执行一次.