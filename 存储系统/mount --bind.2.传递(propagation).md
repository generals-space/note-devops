# mount --bind.2.传递(propagation)

参考文章

1. [Linux VFS文件系统 ----mount命令介绍(二)](https://blog.csdn.net/weixin_37867857/article/details/90512191)
    - 基本的mount命令分为三部分：
        1. 磁盘(块设备)的挂载
        2. 远程计算机目录挂载(如NFS)
        3. 目录绑定(如`--bind`)
    - `mount`命令的`--bind`参数使用方法
2. [Linux mount （第二部分 - Shared subtrees）](https://segmentfault.com/a/1190000006899213)
    - 挂载点是有父子关系的, 比如挂载点`/`和`/mnt/cdrom`，`/mnt/cdrom`都是`/`的子挂载点，`/`是`/mnt/cdrom`的父挂载点
    - shared subtrees就是一种控制子挂载点能否在其他地方被看到的技术, 它只会在bind mount和mount namespace中用到
    - 通过`mount`的`--make-XXX`选项, 有4种类型: 
        - `--make-shared`
        - `--make-slave`
        - `--make-private`(默认)
        - `--make-unbindable`
3. [Linux Namespace系列（04）：mount namespaces (CLONE_NEWNS)](https://segmentfault.com/a/1190000006912742)
    - mount ns 是第一个被加入Linux的 ns, 由于当时没想到还会引入其它的 ns, 所以取名为`CLONE_NEWNS`, 而没有叫`CLONE_NEWMOUNT`

参考文章2中关于`propagation type`, `peer group`的原理太复杂, 对于"传递"的行为分析造成了很大的干扰, 对刚接触的新手来说, 不容易理解.

## 引言

我们知道, 完成`bind`映射的源目录与目标目录是相同的, 对任何一方的内容进行变更, 另一方也会同时发生变更.

那么, 如果在其中一方中, 再挂载一个其他的设备, 另一方会感知到吗? 是双向的吗?

这个问题涉及到挂载点的**父子关系**, 以及**属性继承**的相关知识(就跟面向对象编程一样), 需要实验验证一下.

首先要明确如下几个知识点:

1. "挂载点"一般是指`mount`时的目标目录(是一个绝对路径);
2. "挂载点"是有父子关系的, 这个关系只与挂载点的目录层级有关, 与源目录无关;
    - 如果`/dev/sdb1`挂载到了`/mnt/sdb1`, `/dev/sdb2`挂载到了`/mnt/sdb1/sdb2`, 那么前者就为后者的"父节点";
    - 所有挂载点都是`/`挂载点的子节点;
3. "挂载点"的属性继承行为只表现在"父-子"层面, "祖-孙"之间不会直接相关;

**⚠注意**: 这个场景(本文介绍的"传递"场景), 只会在`mount --bind`与跨`mount ns`时才会用到, 本文的示例中都是基本`bind`的, 关于跨`mount ns`的以后再说.

## bind映射的源目录与目标目录内, 再次挂载(隐藏的`--make-shared`参数)

首先创建`source`源目录与`target`目标目录, 并完成`bind`映射.

```bash
mkdir -p /demo/
cd /demo/
dd if=/dev/zero bs=1M count=32 of=./disk1.img
mkfs.ext2 ./disk1.img
mkdir /mnt/disk1
mount /demo/disk1.img /mnt/disk1

mkdir /mnt/bind1
mount --bind /mnt/disk1 /mnt/bind1
```

其中`/mnt/disk1`为`bind`的源目录, `/mnt/bind1`为目标目录.

然后在`/mnt/disk1`目录下, 再挂载一个设备, 看看`/mnt/bind1`有什么反应.

```
cd /demo
dd if=/dev/zero bs=1M count=32 of=./disk2.img
mkfs.ext2 ./disk2.img
mkdir /mnt/disk1/disk2
mount /demo/disk2.img /mnt/disk1/disk2
```

```log
$ ll /mnt/disk1/disk2
total 12
drwx------ 2 root root 12288 Jan 19 16:07 lost+found
/demo
$ ll /mnt/bind1/disk2
total 12
drwx------ 2 root root 12288 Jan 19 16:07 lost+found
```

诶嘿, 一样, 说明挂载点目录下继续挂载, 是可以反应到对应的`bind`目录的.

但这并不是天经地义的, 在执行`mount /demo/disk1.img /mnt/disk1`创建挂载点的时候, 实际上省略了一个`--make-shared`参数, 这是默认的, 意思是, `bind`目录双方各自的挂载行为, 会分别通知给对方.

## `--make-private`

我们再做个实验.

```bash
mkdir -p /demo/
cd /demo/
dd if=/dev/zero bs=1M count=32 of=./disk3.img
mkfs.ext2 ./disk3.img
mkdir /mnt/disk3
mount --make-private /demo/disk3.img /mnt/disk3

mkdir /mnt/bind2
mount --bind /mnt/disk3 /mnt/bind2
```

这里与第1个实验有点不同, 在创建`bind`源目录的挂载点时, 添加了`--make-private`参数.

该参数表示, `bind`目录双方各自的挂载行为, 不再通知对方.

```
cd /demo
dd if=/dev/zero bs=1M count=32 of=./disk4.img
mkfs.ext2 ./disk4.img
mkdir /mnt/disk3/disk4
mount /demo/disk4.img /mnt/disk3/disk4
```

现在再看看效果

```log
$ ll /mnt/disk3/disk4/
total 12
drwx------ 2 root root 12288 Jan 19 16:31 lost+found
/demo
$ ll /mnt/bind2/disk4/
total 0
```

## `--make-slave`

其实除了上面的`shared`双向通知, `private`双向不通知, 还有一个选项是单向通知`slave`.

我们再做个实验.

```bash
mkdir -p /demo/
cd /demo/
dd if=/dev/zero bs=1M count=32 of=./disk5.img
mkfs.ext2 ./disk5.img
mkdir /mnt/disk5
mount /demo/disk5.img /mnt/disk5

mkdir /mnt/bind3
mount --bind --make-slave /mnt/disk5 /mnt/bind3
```

注意, 这里与第1和第2个实验都有不同, 在创建`bind`源目录`/mnt/disk5`挂载点时, 没有参数, 默认会继承`/`挂载点的属性(一般是`shared`).

而在`--bind`映射目标目录时, 则添加了`--make-slave`, 表示`/mnt/bind3`为slave挂载点, 在ta下面继续挂载, 不会通知源目录`/mnt/disk5`, 但反过来不是.

> 这里之所以选择在`--bind`的时候指定`--make-slave`, 而不是在挂载`/mnt/disk5`时指定, 是因为如果选择后者的话, `slave`端就是`/mnt/disk5`了, 要想创建新的挂载点让ta知道, 就只能在ta的父节点(`/`根挂载点)下新建了, 太麻烦.

```bash
cd /demo
dd if=/dev/zero bs=1M count=32 of=./disk6.img
mkfs.ext2 ./disk6.img
mkdir /mnt/disk5/disk6
mount /demo/disk6.img /mnt/disk5/disk6
```

现在再看看效果

```log
$ ll /mnt/disk5/disk6/
total 12
drwx------ 2 root root 12288 Jan 19 18:06 lost+found
/demo
$ ll /mnt/bind3/disk6/
total 12
drwx------ 2 root root 12288 Jan 19 18:06 lost+found
```

可以看到, 在源目录(`/mnt/disk5/`)下挂载新目录, 是通知到了`slave`端(`/mnt/bind3`)的.

再反过来试一下.

```
cd /demo
dd if=/dev/zero bs=1M count=32 of=./disk7.img
mkfs.ext2 ./disk7.img
mkdir /mnt/bind3/disk7
mount /demo/disk7.img /mnt/bind3/disk7
```

再看一下.

```log
$ ll /mnt/bind3/disk7/
total 12
drwx------ 2 root root 12288 Jan 19 18:08 lost+found
/demo
$ ll /mnt/disk5/disk7/
total 0
```

可以看到, `slave`端(`/mnt/bind3`)下新的挂载点却是没通知给源目录(`/mnt/disk5/`)的. 

> 在`bind3`中创建的`disk7`目录, 同时也修改到了`/mnt/disk5`, 说明双方还是同源的.

## FAQ

### mkisofs 挂载: Read-only

```bash
mkdir -p /demo/iso1/subdir1
cd /demo
mkisofs -o 1.iso ./iso1
mkdir /mnt/iso1 /mnt/iso2
mount --make-shared /demo/1.iso /mnt/iso1

mkdir -p /mnt/target
mount --bind /mnt/iso1 /mnt/target
```

```
mkdir -p /demo/iso2/subdir2
mkisofs -o 2.iso ./iso2
mkdir /mnt/iso1/iso2
mount /demo/2.iso /mnt/iso1/iso2
```

```log
$ mkdir /mnt/iso1/iso2
mkdir: cannot create directory ‘/mnt/iso1/iso2’: Read-only file system
$ cd /mnt/iso1
$ touch abc
touch: cannot touch ‘abc’: Read-only file system
```

不能使用 mkisofs, 只能用 mkfs.ext2 这种.
