# 阿里云Linux云主机ssh出现Connection reset by peer的问题[aliyun]

参考文章

1. [解决 ssh_exchange_identification: read: Connection reset by peer问题](https://blog.csdn.net/lilygg/article/details/86187028)
    - `echo 'sshd: ALL' >> /etc/hosts.allow`无效
2. [意外-一次处理阿里云Linux云主机ssh出现Connection reset by peer的问题](https://blog.51cto.com/xiaozhagn/2477791)
    - 完全符合

某天阿里云突然登录不上了.

```log
$ ssh -v root@xxx.40.66.85
OpenSSH_8.1p1, LibreSSL 2.7.3
debug1: Reading configuration data /Users/general/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 47: Applying options for *
debug1: Connecting to xxx.40.66.85 [xxx.40.66.85] port 22.
debug1: Connection established.
debug1: identity file /Users/general/.ssh/id_rsa type 0
debug1: identity file /Users/general/.ssh/id_rsa-cert type -1
debug1: identity file /Users/general/.ssh/id_dsa type -1
debug1: identity file /Users/general/.ssh/id_dsa-cert type -1
debug1: identity file /Users/general/.ssh/id_ecdsa type -1
debug1: identity file /Users/general/.ssh/id_ecdsa-cert type -1
debug1: identity file /Users/general/.ssh/id_ed25519 type -1
debug1: identity file /Users/general/.ssh/id_ed25519-cert type -1
debug1: identity file /Users/general/.ssh/id_xmss type -1
debug1: identity file /Users/general/.ssh/id_xmss-cert type -1
debug1: Local version string SSH-2.0-OpenSSH_8.1
kex_exchange_identification: read: Connection reset by peer
```

服务端没有报错日志.

按照参考文章2可以解决