# awk if条件判断

参考文章

1. [shell文本过滤编程（三）：awk之条件判断](https://blog.csdn.net/shallnet/article/details/38821311)

基本语法

```
awk '{if(条件){执行的动作}}' 目标文件
```

以如下文件为例(`last -n 5`命令输出)

```log
root        pts/1        172.16.91.1      Tue Aug 31 18:33   still logged in
root        pts/1        172.16.91.1      Mon Aug 30 11:41 - 19:30  (07:48)
general     pts/4        172.16.91.1      Mon Aug 30 11:41 - 19:30  (07:48)
root        pts/7        172.16.91.1      Sun Aug 29 17:44 - 18:36  (00:51)
jiangming   pts/6        172.16.91.1      Sun Aug 29 15:46 - 18:36  (02:49)
```

我们希望过滤出非`root`的记录.

```log
$ awk '{if($1 != "root"){print}}' ./last
general     pts/4        172.16.91.1      Mon Aug 30 11:41 - 19:30  (07:48)
jiangming   pts/6        172.16.91.1      Sun Aug 29 15:46 - 18:36  (02:49)
```
