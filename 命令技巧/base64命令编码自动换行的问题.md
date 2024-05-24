# base64命令编码自动换行的问题

参考文章

1. [shell base64 会自动换行问题](https://blog.csdn.net/zhanw15/article/details/106013372/)

```log
$ base64 python.py
IyEvdXNyL2Jpbi9lbnYgcHl0aG9uCgppbXBvcnQgc3lzCmltcG9ydCB0aW1lCgpwcmludChzeXMu
YXJndlsxXSkKCnRpbWUuc2xlZXAoMTApCgpwcmludCgnZXhpdCcpCg==
```

`base64`生成一个文件的编码, 但是ta的输出会自动换行, 很麻烦.

可以使用`-w`参数, `-w`为每隔多少字符换行, 0表示不换行.

```log
$ base64 -w 0 python.py
IyEvdXNyL2Jpbi9lbnYgcHl0aG9uCgppbXBvcnQgc3lzCmltcG9ydCB0aW1lCgpwcmludChzeXMuYXJndlsxXSkKCnRpbWUuc2xlZXAoMTApCgpwcmludCgnZXhpdCcpCg==
```
