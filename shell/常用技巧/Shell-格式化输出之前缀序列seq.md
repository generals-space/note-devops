# Shell-格式化输出之前缀序列seq

参考文章

1. [在Linux中创建带有前缀0的数值序列的多种方法](https://blog.51cto.com/liusibo/1557850)

参考文章1中主要用的还是`seq`.

这个命令的选项很少, 所以很简单.

## `-f`

可指定类似于`printf`风格的格式化字符串.

...but好像不支持`%d`哦, 输出整型需要使用`%g`, wtf

```console
[root@k8s-worker-7-17 ~]# seq -f '%3d' 3
seq: 格式"%3d" 中包含未知%d 指令
[root@k8s-worker-7-17 ~]# seq -f '%3g' 3
  1
  2
  3
[root@k8s-worker-7-17 ~]# seq -f '%03g' 3
001
002
003
```

## `-w`

这个选项就简单直接很多了, 就是指定输出数值等宽, 不足的以0补全.

```
[root@k8s-worker-7-17 ~]# seq -w 3
1
2
3
[root@k8s-worker-7-17 ~]# seq -w 10
01
02
03
...
10
[root@k8s-worker-7-17 ~]# seq -w 100
001
002
003
...
100
```

...有一种比较特殊的

```
[root@k8s-worker-7-17 ~]# seq -w 03
01
02
03
```

## `-s`

这个指定生成序列的分隔符, 默认是换行`\n`

```
[root@k8s-worker-7-17 ~]# seq -s ' ' -w 03
01 02 03
```

------

```
[fred@Royalmile Auto_Ops]$ touch linux_{8..12}
[fred@Royalmile Auto_Ops]$ ls
linux_10  linux_11  linux_12  linux_8  linux_9
[fred@Royalmile Auto_Ops]$ rename "linux_" "linux_0" linux_?
[fred@Royalmile Auto_Ops]$ ls
linux_08  linux_09  linux_10  linux_11  linux_12
[fred@Royalmile Auto_Ops]$ rename "linux_" "linux_0" linux_??
[fred@Royalmile Auto_Ops]$ ls
linux_008  linux_009  linux_010  linux_011  linux_012
```

这一段关于rename的使用可以查看ta的man手册, 例子还是挺简单的.

`rename expression replacement file`

意思是将文件名中`expression`部分转换为`replacement`的部分, 目标文件则由`file`指定, 可使用通配符.
