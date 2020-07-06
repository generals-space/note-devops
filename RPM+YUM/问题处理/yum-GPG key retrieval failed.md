# yum-GPG key retrieval failed

参考文章

1. [yum使用过程中的常见错误](http://blog.csdn.net/zklth/article/details/6339662)

```
Total download size: 24 M
Is this ok [y/N]: y
Downloading Packages:
(1/25): python26-backports-1.0-5.el5.x86_64.rpm                  | 4.2 kB     00:00     
(2/25): python26-ordereddict-1.1-3.el5.noarch.rpm                | 6.6 kB     00:00     
...
----------------------------------------------------------------------------------------
Total                                                    16 MB/s |  24 MB     00:01     
warning: rpmts_HdrFromFdno: Header V4 DSA signature: NOKEY, key ID 217521f6

GPG key retrieval failed: [Errno 14] HTTP Error 404: Not Found
```

有的说用`rpm --import gpg的key文件`, 这个文件在yum源配置文件的`gpgkey`字段, 导入即可, 不过可能是由于系统版本不太一致(redhat装centos的软件), 所以不太管用.

用`--nogpgcheck`直接跳过这个检查即可.
