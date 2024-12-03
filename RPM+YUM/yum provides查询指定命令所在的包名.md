参考文章

1. [查询Linux某命令来自哪个包](https://blog.csdn.net/qq_26507799/article/details/78998439)

```
yum provides *bin/ifconfig
yum provides *bin/less
```

不知道为啥必须要加`*bin/`.

> 注意: 本地未安装的(即任何`bin`目录都不存在的)命令也可以使用这种方法查找到所在包.

```log
$ yum provides *bin/ifconfig
已加载插件：fastestmirror
Repository epel is listed more than once in the configuration
Repository epel-debuginfo is listed more than once in the configuration
Repository epel-source is listed more than once in the configuration
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * extras: mirrors.aliyun.com
...省略
net-tools-2.0-0.25.20131004git.el7.x86_64 : Basic networking tools
源    ：base
匹配来源：
文件名    ：/sbin/ifconfig

net-tools-2.0-0.25.20131004git.el7.x86_64 : Basic networking tools
源    ：@base
匹配来源：
文件名    ：/sbin/ifconfig
```
