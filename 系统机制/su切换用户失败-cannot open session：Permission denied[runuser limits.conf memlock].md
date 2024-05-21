# su切换用户失败-cannot open session：Permission denied[runuser]

参考文章

1. [解决“su: cannot open session: Permission denied”](http://blog.itpub.net/26736162/viewspace-2683813/)
    - 注释`/etc/pam.d/su`文件中`session include system-auth`这一行
2. [Linux系统root下执行su登录其他用户失败](https://blog.csdn.net/wengjianhong2099/article/details/128258178)
3. [su: permission denied despite being root in oracle container](https://stackoverflow.com/questions/62574379/su-permission-denied-despite-being-root-in-oracle-container)
    - 题主的情况与我的完全相同
    - 答主`user3843990`回答到, 问题根源不是`limits.conf`的"nofile unlimited", 也不是`/etc/pam.d/su`的"session include system-auth"
4. [su: cannot open session: Permission denied](https://unix.stackexchange.com/questions/518270/su-cannot-open-session-permission-denied)

## 问题描述

容器化es启动失败, 发现是`runuser -u elasticsearch elasticsearch`这一行出错了, 手动执行`su`切换用户也会失败.

```
$ su -l elasticsearch
cannot open session: Permission denied
```

不只切换普通用户, 甚至`su -l`从root到root本身也切换失败.

## 排查思路

网上很多文章说是`nofile`设置成了`unlimited`或是`-1`, 但其实并没有这种非法的设置.

### 1. 注释`/etc/pam.d/su`文件中`session include system-auth`这一行

```log
$ cat /etc/pam.d/su
#%PAM-1.0
auth            sufficient      pam_rootok.so
# Uncomment the following line to implicitly trust users in the "wheel" group.
#auth           sufficient      pam_wheel.so trust use_uid
# Uncomment the following line to require a user to be in the "wheel" group.
#auth           required        pam_wheel.so use_uid
auth            substack        system-auth
auth            include         postlogin
account         sufficient      pam_succeed_if.so uid = 0 use_uid quiet
account         include         system-auth
password        include         system-auth
## 注释这一行
# session               include         system-auth
session         include         postlogin
session         optional        pam_xauth.so
```

这个是有效的, 但奇怪的是, 其他容器化es集群所用的镜像和这个集群的镜像是相同的, 之前也从未改动过这个文件. 

感觉这不是问题的根源, 于是继续排查.

### 2. "* hard memlock 134217728"

参考文章3中的问题与我完全相同, 答主`user3843990`回答到, 问题根源不是`limits.conf`的"nofile unlimited", 也不是`/etc/pam.d/su`的"session include system-auth", 而是因为`limits.conf`中`* hard memlock xxx`的相关配置.

的确如此, 在移除`hard memlock`相关配置后, `su -l`切换用户就成功了.

> 只与`hard memlock`有关, `soft memlock`是不影响的.

但还是我上面提到的, 其他容器化集群的配置与该集群的`limits.conf`配置都一致, 且没有出现问题.

## 解决方法

后来继续排查, 发现出问题的pod中缺少了如下权限配置, 导致`memlock`无法正常生效, 所以才报错了.

```yaml
securityContext:
  capabilities:
    add:
    - CAP_SYS_RESOURCE
  privileged: false
```
