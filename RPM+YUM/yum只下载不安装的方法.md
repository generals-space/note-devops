# yum只下载不安装的方法

参考文章

1. [yum只下载软件不安装的两种方法](http://www.linuxidc.com/Linux/2012-06/62664.htm)

yum安装操作的实际都是下载一系列有依赖关系的rpm包再用`rpm`命令安装. 

有时候我只想下载某个软件的rpm而不是直接安装, 比如有一台无法联网的服务器, 想装某个软件时, 你可能需要在网卡到处找对应的rpm包, 然后尝试安装一下, 再到处找它的依赖包...

但是你现在恰好有一台可以联网的, 而且系统版本差不多的服务器, 不如直接在这台服务器上把rpm包都down下来(yum install时可以看到所有的依赖包, 也不用一次次尝试了), 再拷到目标机器上...多美好.

按照参考文章1的说法, 我首先尝试的是`yum-utils`包里的`yumdownloader`命令.

```
$ yumdownloader salt
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
salt-2015.5.10-2.el7.noarch.rpm                                                                                                  | 4.1 MB  00:00:00     
$ ls
salt-2015.5.10-2.el7.noarch.rpm
```

而且!!! 它还有一个`--resolve`参数!!! 能把一个软件包的所有依赖包都下载了!!! 多么美好的事情!!!

```
$ yumdownloader --resolve salt
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
--> Running transaction check
---> Package salt.noarch 0:2015.5.10-2.el7 will be installed
--> Processing Dependency: systemd-python for package: salt-2015.5.10-2.el7.noarch
--> Processing Dependency: python-zmq for package: salt-2015.5.10-2.el7.noarch
--> Finished Dependency Resolution
...
Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
(1/24): PyYAML-3.10-11.el7.x86_64.rpm                                                                                            | 153 kB  00:00:00     
(2/24): dracut-config-rescue-033-502.el7.x86_64.rpm                                                                              |  55 kB  00:00:00     
...
$ ls
dracut-033-502.el7.x86_64.rpm                python2-crypto-2.6.1-15.el7.x86_64.rpm    PyYAML-3.10-11.el7.x86_64.rpm
openpgm-5.2.122-2.el7.x86_64.rpm             python-zmq-14.3.1-1.el7.x86_64.rpm        zeromq3-3.2.5-1.el7.x86_64.rpm
...
```

> 注意: 如果当前服务器上已经安装了某个依赖, 那么`yumdownloader`在`resolve`时是不会再下载的!!!

参考文章1中介绍了两种方法, 除了`yumdownloader`这个独立的工具, 还有一个yum插件`yum-downloadonly`, 当然也是需要安装的.

```
$ yum -y install yum-downloadonly
```

这个插件可以让`yum`支持`--downloadonly`与`--downloaddir`等参数, 前者声明只下载不安装, 后者指定下载的rpm包存放的位置.

使用方法如下

```
$ yum install -y --downloadonly --downloaddir=/tmp salt
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Resolving Dependencies
--> Running transaction check
---> Package salt.noarch 0:2015.5.10-2.el7 will be installed
...
--> Finished Dependency Resolution

Dependencies Resolved

=============================================================================================================================================
 Package                                     Arch                          Version                                 Repository                      Size
=============================================================================================================================================
Installing:
 salt                                        noarch                        2015.5.10-2.el7                         epel                           4.1 M
...
Transaction Summary
=============================================================================================================================================
Install  1 Package (+17 Dependent packages)
Upgrade  1 Package (+ 6 Dependent packages)

Total download size: 15 M
Background downloading packages, then exiting:
Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
(1/25): PyYAML-3.10-11.el7.x86_64.rpm                                                                                            | 153 kB  00:00:00     
(2/25): dracut-033-502.el7.x86_64.rpm                                                                                            | 321 kB  00:00:00       
--------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                    14 MB/s |  15 MB  00:00:01     
exiting because "Download Only" specified
```

看最后一句哦, `exiting because "Download Only" specified`.