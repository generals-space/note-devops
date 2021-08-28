# mount命令应用-传递

参考文章

1. [Linux VFS文件系统 ----mount命令介绍(二)](https://blog.csdn.net/weixin_37867857/article/details/90512191)
2. [Linux Namespace系列（04）：mount namespaces (CLONE_NEWNS)](https://segmentfault.com/a/1190000006912742)

我们知道, mount ns 可以用来隔离挂载点, 所以我们可能会创建多个 mount ns.

但也有一些特殊的设备, 我们希望ta的挂载/卸载操作能够在所有 mount ns 中都被感知到, 要如何做到呢?

通过`mount`的`--make-XXX`选项, 有4种类型: 

- `--make-shared`
- `--make-slave`
- `--make-private`(默认)
- `--make-unbindable`

------

我们知道, `unshare --mount`可以用来模拟一个隔离的 mount ns, 但是默认情况下, `unshare`会将新 mount ns 里面的所有挂载点的类型设置成`private`.

如果在系统中已经存在了一些被标记为 shared 的 mountpoint 挂载点, 在`unshare --mount`时, 新的 mount ns 会继承这些挂载点, 但是这些挂载点会失去原本的标记, 全部变为`private`.

```
unshare --mount --propagation unchanged bash
```
