# yum卡在Running Transaction Test

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
