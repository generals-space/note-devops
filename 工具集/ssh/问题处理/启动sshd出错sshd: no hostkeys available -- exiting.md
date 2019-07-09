# 启动sshd出错sshd: no hostkeys available -- exiting

参考文章

1. [sshd: no hostkeys available — exiting](http://blog.chinaunix.net/uid-25508301-id-2941356.html)

环境是centos7的docker容器, 安装完openssh-server后, 使用`/sbin/sshd`启动服务, 出现如下错误

```
$ /sbin/sshd
Could not load host key: /etc/ssh/ssh_host_rsa_key
Could not load host key: /etc/ssh/ssh_host_ecdsa_key
Could not load host key: /etc/ssh/ssh_host_ed25519_key
sshd: no hostkeys available -- exiting.
```

上述问题是因为`/etc/ssh`目录下不存在这些文件, 需要手动创建. 可使用`ssh-keygen`的`-t`选项指定`rsa|ecdsa|ed25519`加密类型.

如果目录下已存在这些文件仍然报上述错误, 可以检查这些文件的权限, 需要是600.
