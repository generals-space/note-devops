# Linux特殊权限[suid sgid setuid setgid]

参考文章

1. [Linux中的setuid和setgid](https://blog.csdn.net/whu_zhangmin/article/details/21973201)
    - 以`passwd`命令为例, 解释`suid`的使用场景
    - 设置`suid`的方法
    - 禁用`suid`的方法: `nosuid`
2. [Linux权限管理：setUID、setGID 和 Sticky BIT](https://www.cnblogs.com/qiuyu666/p/11818730.html)
    - `sticky BIT`粘滞位的解释的设置方法
3. [linux setuid函数_setuid函数解析](https://blog.csdn.net/weixin_33744799/article/details/114726191)
    - `setuid()`函数的使用详解

## 引言

参考文章1介绍了这样一种典型的场景.

`root`用户与普通用户都可以通过`passwd`命令修改自己的密码, 我们知道, Linux的密码都是保存在`/etc/passwd`和`/etc/shadow`文件中, 而这两个文件只有`root`才有权限修改.

```
$ ll /etc/passwd /etc/shadow
-rw-r--r-- 1 root root 1301 5月   1 2020 /etc/passwd
---------- 1 root root  869 8月  11 2020 /etc/shadow
```

那么问题来了, 普通用户在更改自己的密码的时候, 是怎样持久化到这2个文件的呢?

由此引出本篇文章所要讲述的"特殊"权限的概念.

## 什么是特殊权限?

实际上, 普通用户能更新自己的密码并使其生效, 与`/etc/passwd`和`/etc/shadow`文件的权限没什么关系, 而是跟`passwd`命令有关系.

```console
$ which passwd
/usr/bin/passwd
$ ll /usr/bin/passwd
-rwsr-xr-x. 1 root root 27856 8月   9 2019 /usr/bin/passwd
```

![](https://gitee.com/generals-space/gitimg/raw/master/51045c527961f3d38850205a505a3231.png)

注意`passwd`文件属主的执行权限位置上显示的`s`属性(一般应该`x`属性).

这个属性的存在, 使普通用户在执行`passwd`命令时, 可以暂时拥有该命令的属主(这里是`root`)的权限, 从而将新密码更新到`/etc/passwd`和`/etc/shadow`.

## 如何设置特殊权限?

以`/usr/local/bin/etcdctl`为例

添加`s`权限

```
chmod 4755 etcdctl
```

移除`s`权限

```
chmod 755 etcdctl
```

![](https://gitee.com/generals-space/gitimg/raw/master/bbf29ca3d18dadb9c368359cdce89625.png)

不过如果每次添加/删除`s`属性时, 都要写明后面的`755`, 感觉很危险, 可以使用如下的方式.

添加`s`权限

```
chmod u+s etcdctl
```

移除`s`权限

```
chmod u-s etcdctl
```

## suid sgid

上面的`s`属性即是`suid`, 执行者拥有的是目标程序用户属主的执行权限. 

还有一个类似的属性, 就是`sgid`, 修改的是目标程序用户组的执行权限.

添加用户组`s`权限

```
chmod 2755 etcdctl
## chmod g+s etcdctl
```

移除用户组`s`权限

```
chmod 755 etcdctl
## chmod g-s etcdctl
```

![](https://gitee.com/generals-space/gitimg/raw/master/7a2e704c410f69f5440e35fdb1f2ab4d.png)
