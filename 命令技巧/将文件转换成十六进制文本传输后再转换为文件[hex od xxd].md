# 将文件转换成十六进制文本传输后再转换为文件[hex od xxd]

参考文章

1. [Convert binary mode to text mode and the reverse option](https://unix.stackexchange.com/questions/205635/convert-binary-mode-to-text-mode-and-the-reverse-option)
2. [文件转成16进制hex格式并进行传输，接收后进行还原](https://blog.csdn.net/qq_24815615/article/details/122277386)
    - 转换回来的文件有问题...

将二进制文件转换为文本文件

```
od -An -vtx1 Check.tar > Check.txt
```

再转回来

```
LC_ALL=C tr -cd 0-9a-fA-F < Check.txt | xxd -r -p > Check.tar
```

为了传输效率更高, 可以先将目标文件进行压缩.

