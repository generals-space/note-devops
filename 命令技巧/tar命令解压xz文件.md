# tar命令解压xz文件

参考文章

1. [tar.xz文件如何解压](https://blog.csdn.net/Dyoungwhite/article/details/123955564)

现在有很多语言包都使用`xz`格式进行压缩, 如`Python-3.7.8.tar.xz`, `node-v8.11.3-linux-x64.tar.xz`.

解压方法

```
tar -Jxf ./node-v8.11.3-linux-x64.tar.xz
```

或者用xz命令解压成tar包(类似)

```
xz -d 要解压的文件.tar.gz
```

```
xz -z 要压缩的文件.tar
```
