# Linux-修改时区

参考文章

1. [CentOS7修改时区的正确姿势](http://blog.csdn.net/yin138/article/details/52765089)

2. [CentOS 7 修改时区](http://blog.csdn.net/robertsong2004/article/details/42268701)

```
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

## 1. CentOS7下的坑

网上大部分修改时区用的都是上面的命令, 使用指定时区文件覆盖`/etc/localtime`. 

> 注意: 系统默认的`/etc/localtime`文件应该是一个软链接, `cp`命令强制覆盖不会生效, 只能先将其删除, 再拷贝.

这个命令在CentOS6上面工作正常, 但是CentOS7上却发现运行的Java程序的日志中时间与当前系统时间不一致. 尝试过手动写入如下内容到`/etc/sysconfig/clock`文件, 但是无效.

```
ZONE="Asia/Shanghai"
UTC=false
ARC=false
```

参考文章1中给出了解释.

> 用`cp`命令修改时区, 通过`date`, `data -R`命令显示的时区都是正确的, 可是对于Java程序而言, 是错误的, 具体原因在于Java访问系统时区的方式上, 可参见文章: [Java TimeZone 和 Linux TimeZone问题](https://my.oschina.net/huawu/blog/4646).

Java访问系统时区的方式:  

1. 如有环境变量TZ设置, 则用TZ中设置的时区 

2. 在 `/etc/sysconfig/clock`文件中找`ZONE`的值.

3. 如果2)都没, 就用`/etc/localtime` 和 `/usr/share/zoneinfo` 下的时区文件进行匹配, 如找到匹配的, 就返回对应的路径和文件名.

如果使用cp命令来修改`/etc/localtime`文件, 那么可能就会导致修改的不是`/etc/localtime`文件, 而是原时区的文件内容. 即把原来软链接指向的文件给覆盖了, 原文件的文件名没变, 但内容成了`Shanghai`那个文件了. 

`/etc/localtime`是通过符号链接链接`/usr/share/zoneinfo`下的文件, 而java是通过**文件名**来确认时区的, data命令是通过**文件内容**确认时区的, 这样就导致了data命令时区正确, 而java的时区是错误的. 

> 实际实验时`TZ`环境变量的确有效, 比如`export TZ=Asia/Shanghai && java xxxx`时日志正常, 但是那个`clock`文件根本没用.

正确的修改CentOS7 时区的姿势: 

```
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

> 注意: 即使事先将`/etc/localtime`软链接删除, 再拷贝`Shanghai`的时区文件过去, Java程序也是不认的. 因为它读到的文件名也就是时区名是`localtime`, 但实际上不存在这个时区, 所以会用默认时区了.

## CentOS7提供的内置命令

在 CentOS 7 中, 引入了一个叫`timedatectl`的时区设置程序.

用法很简单, `--help`一下就能明白. 就是列出可用时区, 设置当前时区, 查看当前时区状态等.

```
$ timedatectl status
Warning: Ignoring the TZ variable. Reading the system's time zone setting only.

      Local time: Fri 2018-01-12 14:22:18 CST
  Universal time: Fri 2018-01-12 06:22:18 UTC
        RTC time: Fri 2018-01-12 06:22:18
       Time zone: Asia/Shanghai (CST, +0800)
     NTP enabled: yes
NTP synchronized: no
 RTC in local TZ: no
      DST active: n/a
```

其中有一个选项`set-local-rtc`, 它是一个布尔值(0或1就可以), 它的作用是将硬件时钟调整为与本地当前时钟一致. 0表示设置为UTC时间. 这个硬件时间应该是主板上的时间, 可能会有程序去读这个时间, 不过还没见过.