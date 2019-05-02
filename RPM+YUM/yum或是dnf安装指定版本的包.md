# yum或是dnf安装指定版本的包

一般版本指定应该是安装出错时的提示, 自行安装时不会需要某指定版本的. 比如fedora 22安装某软件出错提示如下:

```
Error: package mariadb-devel-1:10.0.17-1.fc22.x86_64 requires mariadb-libs(x86-64) = 1:10.0.17-1.fc22, but none of the providers can be installed.
```

fedora默认的软件版本都比较新, rpm查询时得到

```shell
$ rpm -qa 'mariadb-libs'
mariadb-libs-10.0.21-1.fc22.x86_64
```

根据给出的包与其版本的格式(`包名-版本号-系统平台-位数`)尝试安装一下指定版本

```shell
$ dnf install mariadb-libs-1:10.0.17-1.fc22.x86_64
Last metadata expiration check performed 16:24:36 ago on Mon Feb 22 17:01:22 2016.
Error: cannot install both mariadb-libs-1:10.0.17-1.fc22.x86_64 and mariadb-libs-1:10.0.21-1.fc22.x86_64
(try to add '--allowerasing' to command line to replace conflicting packages)
```

这个情况的出现应该就是当其已经安装的与将要安装的包冲突了, 根据提示, 使用`--allowerasing`选项可强制"降级安装".

```
$ dnf install mariadb-1:10.0.17-1.fc22.x86_64 --allowerasing
Last metadata expiration check performed 16:34:02 ago on Mon Feb 22 17:01:22 2016.
Dependencies resolved.
```

当然, 如果提示有包依赖依然需要一层一层解决的.
