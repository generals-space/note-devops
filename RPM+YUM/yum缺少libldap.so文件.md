# yum缺少libldap.so文件

参考文章

1. [yum命令后出现libldap-2.4.so.2: cannot open shared object file](http://blog.csdn.net/qq_38298869/article/details/72547271)

系统: CentOS7

```
$ yum search abc
There was a problem importing one of the Python modules
required to run yum. The error leading to this problem was:

   liblber-2.4.so.2: cannot open shared object file: No such file or directory

Please install a package which provides this module, or
verify that the module is installed correctly.

It's possible that the above module doesn't match the
current version of Python, which is:
2.7.5 (default, Aug  4 2017, 00:39:18) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-16)]

If you cannot solve this problem yourself, please go to 
the yum faq at:
  http://yum.baseurl.org/wiki/Faq
```

原因是我卸载了之前安装的`ldap-devel`...它好像多卸载了一些东西才导致了这个错误, 这些东西被ldap和yum共同需要...

按照参考文章1中的方法, 得以解决.

第一个, 如果直接`-ivh`没法安装上的话, 尝试添加`--nodeps`参数.

```
[root@dev-cmdb grafana]# rpm -ivh [--nodeps] ./openldap-2.4.44-5.el7.x86_64.rpm
Preparing...                          ################################# [100%]
	package openldap-2.4.44-5.el7.x86_64 is already installed
[root@dev-cmdb grafana]# rpm -ivh ./openldap-clients-2.4.44-5.el7.x86_64.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:openldap-clients-2.4.44-5.el7    ################################# [100%]
[root@dev-cmdb grafana]# rpm -ivh openldap-devel-2.4.44-5.el7.x86_64.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:openldap-devel-2.4.44-5.el7      ################################# [100%]
[root@dev-cmdb grafana]# rpm -ivh openldap-servers-2.4.44-5.el7.x86_64.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:openldap-servers-2.4.44-5.el7    ################################# [100%]
^[[A[root@dev-cmdb grafana]# rpm -ivh openldap-servers-sql-2.4.44-5.el7.x86_64.rpm
error: open of ivh failed: No such file or directory
[root@dev-cmdb grafana]# rpm -ivh  openldap-servers-sql-2.4.44-5.el7.x86_64.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:openldap-servers-sql-2.4.44-5.el7################################# [100%]
[root@dev-cmdb grafana]# rpm -ivh  compat-openldap-2.3.43-5.el7.x86_64.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:compat-openldap-1:2.3.43-5.el7   ################################# [100%]
```

然后就可以了.

```
 yum search abc
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * epel: mirrors.aliyun.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
...
```