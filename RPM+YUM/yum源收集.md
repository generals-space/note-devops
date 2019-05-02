# yum源收集

## 1. webtatic

centos下的php版本有点老, 可以使用`webtatic`库. 安装方法见[这里](https://webtatic.com/projects/yum-repository/)

查看目标包.

```
yum search php56w
```

这个源里包含了php基本上所有版本及常用的与之匹配的模块和插件等, 可以自由选择.

## 2. ius

这个源包含了centos/redhat某版本的系统中常用的, 也是较新的软件包.

比如, 在这个源里, centos6的php只有7.0版...

常用的包如haproxy, httpd, mysql等, 可以直接使用这个源以安装较新版本, 很方便.

安装方法见[阿里云开源镜像站](https://opsx.alibaba.com/mirror)

