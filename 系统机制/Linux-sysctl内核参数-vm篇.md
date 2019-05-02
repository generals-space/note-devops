# Linux-sysctl内核参数-vm篇

## 1. vm.block_dump

参考文章

1. [找出linux服务器IO占用高的程序](http://blog.csdn.net/onlyforcloud/article/details/47017787)

CentOS5下没法用iotop, 没办法直观地看出哪个进程占用的IO资源. 将这个字段的值设置为1.

```
sysctl vm.block_dump=1
```

开启后内核会将IO读写dump到日志, 通过`dmesg`命令可以查看. 类似于如下

```
$ dmesg
sendmail(31543): WRITE block 18212344 on sda1
kjournald(633): WRITE block 10070104 on sda1
...
```

统计当前占用IO最高的10个进程:

```
$ dmesg |awk -F: '{print $1}'|sort|uniq -c|sort -rn|head -n 10
   1664 kjournald(633)
    439 java(20057)
    356 sendmail(31543)
     47 pdflush(20266)
      6 awk(31880)
      4 bash(31880)
      2 java(31327)
      1 onsumer.concurrent) on sda2
      1 head(31884)
      1 bash(31884)
```

括号里的应该是pid.

用完后记得关闭这个配置项.