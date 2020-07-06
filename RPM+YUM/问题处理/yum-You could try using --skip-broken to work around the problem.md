# yum-You could try using --skip-broken to work around the problem

参考文章

1. [解决 You could try using --skip-broken to work around the problem](http://blog.csdn.net/xc_gxf/article/details/8250983)

情境描述

yum安装软件包(或update)时, 报错如下, 重启不起作用

```shell
http://mirrors.aliyun.com/centos/6/extras/x86_64/repodata/a12ccd4c45ca18ed3807a728184d156b02494e0fa95ff8e6ffe04e95eae4c35b-filelists.sqlite.bz2: [Errno 14] PYCURL ERROR 22 - "The requested URL returned error: 404 Not Found"
Trying other mirror.
Error: failure: repodata/a12ccd4c45ca18ed3807a728184d156b02494e0fa95ff8e6ffe04e95eae4c35b-filelists.sqlite.bz2 from extras: [Errno 256] No more mirrors to try.
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
```

解决方法

```shell
yum clean all
rpm --rebuilddb
yum update
```
