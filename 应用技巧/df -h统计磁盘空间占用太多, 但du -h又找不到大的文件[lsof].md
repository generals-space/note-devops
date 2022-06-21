# df -h统计磁盘空间占用太多, 但du -h又找不到大的文件

参考文章

1. [Linux 显示隐藏目录或隐藏文件的占用空间](http://blog.csdn.net/rav009/article/details/53049441)
2. [df空间满，du找不到文件的问题](https://dandelioncloud.cn/article/details/1481231326341844993)
    - 很好的文章, 很深入
3. [处理一次服务器磁盘df查看没有空间了，但是du -sh *查看找不到占用的文件](https://blog.csdn.net/weixin_43025071/article/details/119356616)

## 1. 查看隐藏文件

```
du -sh .[!.]*
```

## 2. lsof查看占用的进程

按照参考文章2和3, 可以使用`lsof | grep delete`, 查看已经被删掉, 但是仍然正在运行的进程占用的文件, 只要把进程杀掉, 就可以解除占用.

但是我在服务器上执行`lsof`时, 卡住了, 因为lsof的输出实在是太多了, cpu占用率会到100%(单核占满). 而且让ta慢慢执行, 一段时间后就会因为OOM被干掉, 啥也得不到...

正确的解决方法是, `lsof 目标目录 | grep delete`, 输出会少很多.
