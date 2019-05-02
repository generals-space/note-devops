# RPM包制作

参考文章

1. [ 一堂课玩转rpm包的制作](http://blog.chinaunix.net/uid-23069658-id-3944462.html)

2. [一步步制作RPM包](http://laoguang.blog.51cto.com/6013350/1103628)

## 1. 声明

1. rpm包不解决依赖, 只能在包里写入依赖, 用户在用yum安装时可以事先下载依赖

2. 制作rpm之前本机也需要事先解决依赖

3. 安装rpm实际上是把rpm包中预先编译好的文件直接拷贝到指定目录(系统约定, 无需手动编写), 安装者需要事先解决其中可执行文件动态链接库的依赖

4. 所以rpm包的**制作过程**实际上是一次源码编译过程

## 1. 环境准备和认识

安装打包工具

要用到的是`rpmbuild`这个命令, 在`rpmdevtools`这个包里面

```
$ yum install rpmdevtools -y
```

默认情况下打包需要在特定的目录下进行, 通过如下命令建立工作目录, 一般是在`~/rpmbuild`目录下.

```
$ rpmdev-setuptree
```

```
[root@localhost rpmbuild]# cd /root/rpmbuild/
[root@localhost rpmbuild]# tree
.
├── BUILD
├── RPMS
├── SOURCES
├── SPECS
└── SRPMS

5 directories, 0 files
```

它们的作用分别是

|    目录名    |         说明	        |        macros中的宏名        |
|:---------:|:-----------------------------:|----------------|
|   BUILD   |          编译rpm包的临时目录}         | %_builddir     |
| BUILDROOT |        编译后生成的软件临时安装目录}        | %_buildrootdir |
|    RPMS   |       最终生成的可安装rpm包的所在目录}      | %_rpmdir       |
|  SOURCES  |        所有源代码和补丁文件的存放目录}       | %_sourcedir    |
|   SPECS   |        存放SPEC文件的目录}(重要)       | %_specdir      |
|   SRPMS   | 软件最终的rpm源码格式存放路径}暂时忽略掉，别挂在心上) | %_srcrpmdir    |

`_topdir`就是我们的工作目录.

```
 rpmbuild --showrc | grep topdir 
-14: _builddir	%{_topdir}/BUILD
-14: _buildrootdir	%{_topdir}/BUILDROOT
-14: _rpmdir	%{_topdir}/RPMS
-14: _sourcedir	%{_topdir}/SOURCES
-14: _specdir	%{_topdir}/SPECS
-14: _srcrpmdir	%{_topdir}/SRPMS
-14: _topdir	%(echo $HOME)/rpmbuild
```

生成我们最重要的`.spec`文件, 这个`.spec`有点像`Makefile`, 描述了整个工程, 包括生成包的名称, 版本, 架构等.

```
$ rpmdev-newspec -o salt-20161105.spec
```

这条命令会在当前目录下创建`salt-20161105.spec`文件. 建议放在`~/rpmbuild/`根目录下, 因为`rpmbuild`的默认搜索路径就在`~/rpmbuild`, 这样可以不写绝对路径.

## rpmbuild选项

使用方法

```
$ rpm 选项 .spec文件
```

`-ba`: 既生成src.rpm又生成二进制rpm 

`-bs`: 只生成src的rpm 

`-bb`: 只生二进制的rpm 

`-bp`: 执行到pre 

`-bc`: 执行到 build段 

`-bi`: 执行install段 

`-bl`: 检测有文件没包含 
