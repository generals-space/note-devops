# rpm命令应用

参考文章

1. [如何解压RPM包](http://www.cnblogs.com/cool4ever/p/5734202.html)

2. [查看RPM包里的内容](http://blog.csdn.net/yetyongjin/article/details/6735165)

查看rpm包的内容

```
$ rpm -qpl xxx.rpm
```

解压rpm包(RPM包是使用`cpio`格式打包的, 因此可以先转成`cpio`然后解压)

```
$ rpm2cpio xxx.rpm | cpio -div
```

