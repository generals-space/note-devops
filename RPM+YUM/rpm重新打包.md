# rpm重新打包

参考文章

1. [请教：如何修改现有RPM包内部文件？](http://bbs.chinaunix.net/thread-2173735-1-1.html)

场景描述

saltstack通过yum安装后在`CentOS 5`下的启动脚本有点问题, 想给它改点内容, 再打个包放到内网源, 替换一下.

我们首先下载salt的`.src.rpm`包, 本来也下过`.rpm`的包的, 不过没找到头绪, 看到参考文章1中的提示后才找的源码rpm包.

貌似yum源中源码rpm有独立的子目录, 名为`SRPMS`, 路径为`saltstack/5/x86_64/latest/SRPMS/`, 在系统, 架构的分类下.

安装rpm的打包工具

```
$ yum install rpmdevtools -y
```

然后创建编译rpm包时的目录结构, 因为之后重新打包需要这样的结构.

```
$ rpmdev-setuptree
```

这将创建`~/rpmbuild`目录, 目录下有`BUILD`, `BUILDROOT`, `RPMS`, `SOURCES`, `SPECS`, `SRPMS`5个子目录.

把salt的`.src.rpm`包移到`SOURCES`目录下, 解压

解压命令

```
$ rpm2cpio salt-2016.11.3-2.el5.src.rpm | cpio -div
```

然后把`.src.rpm`原文件删掉, 把`.spec`文件移到`~/rpmbuild`根目录下. 这样编译的目录结构就完成了.

然后执行`rpmbuild -ba spec文件名`就可以执行编译动作了. 默认会查找`~/rpmbuild`下的`.spec`文件, 所以可以不用写完整路径.

`-ba`的意思就是既生成`.src.rpm`包, 也生成`.rpm`包.