<!--
<!key!>: {a4fdeb45-7d50-48ac-851b-015c97eb340d}
<!link!>: {note-cloud:8ac2d6d9-b4a7-4551-87a0-cb2af8f0c81f}
-->

参考文章

1. [ubuntu中的apparmor](https://blog.csdn.net/cooperdoctor/article/details/84062206)
2. [Ubuntu Apparmor 简介以及如何配置 Apparmor 配置文件](https://bbs.huaweicloud.com/blogs/371946)
    - AppArmor 配置文件是按**逐个容器**的形式来设置的

ubuntu: 20.04

ubuntu下的apparmor, 与centos下的selinux类似, 可以对当前主机上**已知**服务的进行限制, 包括目标服务能够访问的文件, 目录的限制, 以及网络方面的限制.

## apparmor的开启和关闭

在centos上, 在做操作前经常会先关闭`selinux`, 在ubuntu上也是, 可以使用`systemctl`(或者`/etc/init.d/apparmor`)命令完成.

## 配置

apparmor有两个配置, `/etc/apparmor`和`/etc/apparmor.d`, 前者是对`apparmor`自身的配置, 后者则是`apparmor`对其他服务进行限制配置.

在`/etc/apparmor.d`下, 每个受apparmor控制的应用可以用一个独立的配置文件, 并且配置文件的名字与应用的路径和名字强制关联. 如

- `/bin/ping`的配置为`/etc/apparmor.d/bin.ping`
- `/usr/sbin/cupsd`的配置为`/etc/apparmor.d/usr.sbin.cupsd`

~~修改应用名或路径后, 相应的配置文件将会失效.~~

...不过在我实践过程中, `/etc/apparmor.d`下的文件名格式并不重要, 上述文件主要是`apparmor`自带配置文件的格式, 其实可以随便命名.

------

每个配置文件的格式如下

```conf
# 文件名: nginx

#include <tunables/global>
profile nginx-profile-1 flags=(attach_disconnected) {
    #include <abstractions/base>
    file,
    # Deny all file writes.
    deny /** w,
}
```

每在`/etc/apparmor.d`目录下新增一个配置, 可以使用`apparmor_parser /etc/apparmor.d/文件名`加载, 也可以使用`systemctl restart apparmor`重启整个服务.

```
apparmor_parser /etc/apparmor.d/nginx
```

然后使用`apparmor_status`查看.

```log
$ apparmor_status
apparmor module is loaded.
31 profiles are loaded.
31 profiles are in enforce mode.
   ## ...省略
   nginx-profile-1  ## 这里是 profile 名称.
   ## ...省略
0 profiles are in complain mode.
16 processes have profiles defined.
16 processes are in enforce mode.
   ## 如果有进程匹配到 /etc/apparmor.d/ 下的 profile 配置, 会出现在这里.
0 processes are in complain mode.
0 processes are unconfined but have a profile defined.
```

## enforcing complain 模式

