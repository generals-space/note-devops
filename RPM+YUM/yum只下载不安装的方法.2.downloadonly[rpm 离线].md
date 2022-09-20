# yum只下载不安装的方法[rpm]

参考文章

1. [yum只下载软件不安装的两种方法](http://www.linuxidc.com/Linux/2012-06/62664.htm)

参考文章1中介绍了两种方法, 除了`yumdownloader`这个独立的工具, 还有一个yum插件`yum-downloadonly`, 当然也是需要安装的.

```
yum -y install yum-downloadonly
```

这个插件可以让`yum`支持`--downloadonly`与`--downloaddir`等参数, 前者声明只下载不安装, 后者指定下载的rpm包存放的位置.

使用方法如下

```console
$ yum install -y --downloadonly --downloaddir=/tmp salt
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Resolving Dependencies
--> Running transaction check
---> Package salt.noarch 0:2015.5.10-2.el7 will be installed
...
--> Finished Dependency Resolution

Dependencies Resolved

======================================================================================================================================
 Package                                     Arch                          Version                          Repository                      Size
======================================================================================================================================
Installing:
 salt                                        noarch                        2015.5.10-2.el7                  epel                           4.1 M
...
Transaction Summary
========================================================================================================================
Install  1 Package (+17 Dependent packages)
Upgrade  1 Package (+ 6 Dependent packages)

Total download size: 15 M
Background downloading packages, then exiting:
Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
(1/25): PyYAML-3.10-11.el7.x86_64.rpm                                                                | 153 kB  00:00:00 
(2/25): dracut-033-502.el7.x86_64.rpm                                                                | 321 kB  00:00:00 
------------------------------------------------------------------------------------------------------------------------
Total                                                                                        14 MB/s |  15 MB  00:00:01 
exiting because "Download Only" specified
```

看最后一句哦, `exiting because "Download Only" specified`.
