# SSH(-o)选项参数.1.StrictHostKeyChecking是否检查目标主机公钥

参考文章

1. [Linux之ssh连接保持与重用](http://www.ttlsa.com/linux/linux-ssh-connection-reuse/)
2. [通过 ControlMaster 对 OpenSSH 进行加速，减少系统资源消耗](https://www.ibm.com/developerworks/community/blogs/IBMzOS/entry/20150502?lang=en)
3. [ssh StrictHostKeyChecking](https://www.jianshu.com/p/ebcf41c75786)
    - 一劳永逸

此选项默认值为yes.

在ssh连接目标服务器时, 如果在`~/.ssh/knows_hosts`文件中, 没有存储目标主机的公钥, ssh客户端会提示接受目标公钥. 

```console
$ ssh root@192.168.166.220
The authenticity of host '192.168.166.220 (192.168.166.220)' can't be established.
RSA key fingerprint is 3c:67:0e:d5:1b:28:30:28:f4:62:15:e4:1d:ea:fb:76.
Are you sure you want to continue connecting (yes/no)? 
```

尤其是如果对方重装过系统, `known_hosts`文件存储的公钥与新公钥不一致时, 会报错而终止.

```console
$ ssh root@192.168.166.220
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that the RSA host key has just been changed.
The fingerprint for the RSA key sent by the remote host is
3c:67:0e:d5:1b:28:30:28:f4:62:15:e4:1d:ea:fb:76.
Please contact your system administrator.
Add correct host key in /app/jiale.huang/.ssh/known_hosts to get rid of this message.
Offending key in /app/jiale.huang/.ssh/known_hosts:1260
RSA host key for 192.168.166.220 has changed and you have requested strict checking.
Host key verification failed.
```

将StrictHostKeyChecking设置为`no`后就不会有这种情况.

```console
$ ssh -o 'StrictHostKeyChecking no' root@192.168.166.220
Warning: Permanently added '192.168.166.220' (RSA) to the list of known hosts.
Last login: Sat Dec 30 20:39:42 2017 from 192.168.101.65
[root@220 ~]# 
```

> `StrictHostKeyChecking`选项不是不检查, 而是默认接受对方公钥. 但如果存储的公钥与目标公钥不一致时, 虽然也能正常登录, 但不会更新新的公钥(旧的公钥依然存在).

一劳永逸型.

```
Host *
  StrictHostKeyChecking no
```
