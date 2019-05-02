# Linux错误-yum

## 1. 

[参考文章](http://www.linuxquestions.org/questions/debian-26/release-file-for-is-expired-915460-print/)

```
E: Release file for http://mirrors.aliyun.com/debian/dists/testing/InRelease is expired (invalid since 11d 7h 58min 59s). Updates for this repository will not be applied.
```

问题描述:

之前有使用过这个镜像源在docker容器中进行`update`操作, 后来中途停止了, 第二天重新再使用时报这个错. 按理不应该是由于容器缓存的问题, 因为每次操作都启动的新容器, 所以手动删除了`/var/lib/apt/lists/partial/*`文件后, `update`操作还是不成功.

错误分析:

不太清楚, 也许是镜像源的问题, 换成了网易的镜像源就可以了.

附上`/etc/apt/sources.list`的镜像配置.

```
deb http://mirrors.aliyun.com/ubuntu/ raring main restricted universe multiverse  
deb http://mirrors.aliyun.com/ubuntu/ raring-security main restricted universe multiverse  
deb http://mirrors.aliyun.com/ubuntu/ raring-updates main restricted universe multiverse  
deb http://mirrors.aliyun.com/ubuntu/ raring-proposed main restricted universe multiverse  
deb http://mirrors.aliyun.com/ubuntu/ raring-backports main restricted universe multiverse  
deb-src http://mirrors.aliyun.com/ubuntu/ raring main restricted universe multiverse  
deb-src http://mirrors.aliyun.com/ubuntu/ raring-security main restricted universe multiverse  
deb-src http://mirrors.aliyun.com/ubuntu/ raring-updates main restricted universe multiverse  
deb-src http://mirrors.aliyun.com/ubuntu/ raring-proposed main restricted universe multiverse  
deb-src http://mirrors.aliyun.com/ubuntu/ raring-backports main restricted universe multiverse 
```