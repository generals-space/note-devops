# linux错误 - yum

## 1.

[解决 You could try using --skip-broken to work around the problem](http://blog.csdn.net/xc_gxf/article/details/8250983)

### 情境描述

yum安装软件包(或update)时, 报错如下, 重启不起作用

```shell
http://mirrors.aliyun.com/centos/6/extras/x86_64/repodata/a12ccd4c45ca18ed3807a728184d156b02494e0fa95ff8e6ffe04e95eae4c35b-filelists.sqlite.bz2: [Errno 14] PYCURL ERROR 22 - "The requested URL returned error: 404 Not Found"
Trying other mirror.
Error: failure: repodata/a12ccd4c45ca18ed3807a728184d156b02494e0fa95ff8e6ffe04e95eae4c35b-filelists.sqlite.bz2 from extras: [Errno 256] No more mirrors to try.
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
```

### 解决方法

```shell
yum clean all
rpm --rebuilddb
yum update
```

## 2. 

yum安装时意外中断, 再次运行时出现如下错误

```
yum [Errno 256] No more mirrors to try
```

解决办法

```
yum clean all
```

## 3. gpg key的问题


参考文章

1. [yum使用过程中的常见错误](http://blog.csdn.net/zklth/article/details/6339662)

```
Total download size: 24 M
Is this ok [y/N]: y
Downloading Packages:
(1/25): python26-backports-1.0-5.el5.x86_64.rpm                  | 4.2 kB     00:00     
(2/25): python26-ordereddict-1.1-3.el5.noarch.rpm                | 6.6 kB     00:00     
...
----------------------------------------------------------------------------------------
Total                                                    16 MB/s |  24 MB     00:01     
warning: rpmts_HdrFromFdno: Header V4 DSA signature: NOKEY, key ID 217521f6

GPG key retrieval failed: [Errno 14] HTTP Error 404: Not Found
```

有的说用`rpm --import gpg的key文件`, 这个文件在yum源配置文件的`gpgkey`字段, 导入即可, 不过可能是由于系统版本不太一致(redhat装centos的软件), 所以不太管用.

用`--nogpgcheck`直接跳过这个检查即可.

## 4. Running Transaction Test

参考文章

1. [yum卡在Running Transaction Testde](http://blog.chinaunix.net/uid-20237628-id-3444406.html)

yum install卡在`Running Transaction Test`

```
...
Running rpm_check_debug 
Running Transaction Test
```

`yum clean all`没有用, 真正原因可能是这台服务器挂载过NFS, 但是现在NFS server挂了, 于是这个挂载就锁住了.

这种情况下无法使用`cd`进入挂载目录, `df`命令也会卡住.

在参考文章中提到, `umount命令`会提示NFS不存在. 对应解决方法是, 编辑`/etc/mtab`, 删除NFS目录挂载的行, 然后执行`mount -a`重新挂载有效目录即可.

这一段没太理解, 在我遇到的情况中, `mount`倒是可以看到挂载的NFS目录, 使用`umount -l 被挂载目录`强制移除挂载, 然后`yum`就可以正常使用了.
