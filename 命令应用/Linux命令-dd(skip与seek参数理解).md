# Linux命令-dd(skip与seek参数理解)

参考文章

1. [dd sKip 和 seek参数理解](http://blog.csdn.net/do2jiang/article/details/5069536)

2. [Linux使用dd命令快速生成大文件](http://blog.csdn.net/bug1314/article/details/43152225)


假如我有一个文件`abc.gz`, 大小为83456k, 我想用dd命令实现如下备份 结果：首先将备份分成三个部分, 第一部分为备份文件`abc.gz`的前10000k, 第二部分为中间的70000k, 最后备份后面的3456k. 

备份方法如下三条命令：

```
$ dd if=abc.gz of=abc.gz.bak1 bs=1k count=10000
$ dd if=abc.gz of=abc.gz.bak2 bs=1k skip=10000 count=70000 
$ dd if=abc.gz of=abc.gz.bak3 bs=1k skip=80000 
```

恢复方法如下：

```
$ dd if=abc.gz.bak1 of=abc.gz
$ dd if=abc.gz.bak2 of=abc.gz bs=1k seek=10000
$ dd if=abc.gz.bak3 of=abc.gz bs=1k seek=80000
```

这时你查看一下恢复的文件将和你原来的文件一模一样, 说明备份成功!

理解说明: 

`skip=xxx`是在备份时对`if`后面的部分也就是原文件跳过多少块再开始备份;

`seek=xxx`则是在备份时对`of`后面的部分也就是目标文件跳过多少块再开始写.  

------

参考文章2中有使用`seek`参数快速生成大文件的方法, 但是不好用...但我觉得理论上是可行的, 这里记录下, 看看之后有没有正确方法.