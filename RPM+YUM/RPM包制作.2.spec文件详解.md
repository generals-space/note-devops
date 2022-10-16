# RPM包制作之.spec文件详解

参考文章

1. [ 一堂课玩转rpm包的制作](http://blog.chinaunix.net/uid-23069658-id-3944462.html)

以一个saltstack的rpm包为例

```
salt-minion-2016.11.3-2.el5.noarch.rpm
```

`BuildArch`: 默认noarch(也有`x86_64`, `i386`可选)