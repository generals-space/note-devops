# Shell-for..in..遍历文件列表时对空格的处理[IFS]

参考文章

1. [for循环间隔修改（解决把以空格隔开需要把一整行作为整体）](https://www.cnblogs.com/leo001/p/11259060.html)
2. [linux shell中for循环，如何读取整一行](https://www.jianshu.com/p/ab25c0710583)
    - `IFS="\n" `将字符`n`作为`IFS`分隔符
    - `IFS=$"\n"`这里`\n`确实通过`$`转化为了换行符, 但仅当被解释时（或被执行时）才被转化为换行符;第一个和第二个是等价的
    - `IFS=$'\n'`这才是真正作为分隔符的换行符

## 场景描述

遍历一个目录下, 希望得到该目录下的所有文件名称并做一些处理, 最常见的方法就是

```bash
for i in $(ls /root); do
    echo $i
done
```

但如果某些文件名称中包含空格, 那么`$i`取到的就是被错误分割的名称了.

比如, 当前目录存在一个`test blank`文件

```bash
$ ls
test blank
```

使用上述方法得到的结果会是如下, "test"和"blank"两个单词被分割了.

```bash
$ for i in $(ls); do echo $i; done
test
blank
```

## 处理方法 - while read

参考文章2提到了一种使用`while read`的方法, 与我之前写的"按行读取文件"文章很相似, 如下

```bash
while read i
do 
  echo $i
done <temp.list
```

但这要求数据源是一个文件, 没有办法通过`$(ls xxx)`命令去指定一个目录, 除非事先通过`ls xxx > temp.list`将列表写到这个文件中.

## 处理方法 - IFS

另一种方法就是修改IFS分隔符, 将通过空格分隔修改为通过换行分隔.

```bash
## 注意: IFS为$'\n', 不是"\n"也不是$"\n"
OLDIFS=$IFS;IFS=$'\n';
for i in $(ls); do
    echo $i
done
IFS=$OLDIFS
```

这样就可以了.
