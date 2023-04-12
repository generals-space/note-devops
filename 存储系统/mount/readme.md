参考文章

1. [Linux mount （第一部分）](https://segmentfault.com/a/1190000006878392)
    - mount 命令的参数及含义
    - 挂载 proc、tmpfs、sysfs、devpts等虚拟文件系统的方法
    - `mount --bind`的使用方法, readonly bind
    - `mount --move`参数移动挂载点到另一个目录
2. [Linux mount （第二部分 - Shared subtrees）](https://segmentfault.com/a/1190000006899213)
    - 挂载点是有父子关系的，比如挂载点`/`和`/mnt/cdrom`，`/mnt/cdrom`都是`/`的子挂载点，`/`是`/mnt/cdrom`的父挂载点
3. [Linux Namespace系列（04）：mount namespaces (CLONE_NEWNS)](https://segmentfault.com/a/1190000006912742)
    - mount ns 是第一个被加入Linux的 ns, 由于当时没想到还会引入其它的 ns, 所以取名为`CLONE_NEWNS`, 而没有叫`CLONE_NEWMOUNT`
    - mount ns 用来隔离文件系统的挂载点, 使得不同的 mount ns 拥有自己独立的挂载点信息, 不同的 ns 之间不会相互影响, 这对于构建用户或者容器自己的文件系统目录非常有用
    - 当前进程所在 mount ns 里的所有挂载信息可以在`/proc/[pid]/mounts`、`/proc/[pid]/mountinfo`和`/proc/[pid]/mountstats`里面找到
4. [mount系统调用初探](https://zhuanlan.zhihu.com/p/36268333)
    - `mount`系统调用所有`flags`与`data`参数的示例与解释
    - flags + data对应mount命令的所有-o选项. 可以通俗的认为:
        1. `flags`就是所有文件系统通用的挂载选项，由VFS层解析。
        2. `data`是每个文件系统特有的挂载选项，由文件系统自己解析。

所谓"挂载点", 应该是指`mount`时的目标目录.
