# SSH(-o)选项参数.1.StrictHostKeyChecking是否检查目标主机公钥

参考文章

1. [Linux之ssh连接保持与重用](http://www.ttlsa.com/linux/linux-ssh-connection-reuse/)
2. [通过 ControlMaster 对 OpenSSH 进行加速，减少系统资源消耗](https://www.ibm.com/developerworks/community/blogs/IBMzOS/entry/20150502?lang=en)
3. [ssh StrictHostKeyChecking](https://www.jianshu.com/p/ebcf41c75786)
    - 一劳永逸
4. [HowTo: Disable SSH Host Key Checking](https://www.shellhacks.com/disable-ssh-host-key-checking/)
    - `UserKnownHostsFile=/dev/null`
5. [How do I skip the "known_host" question the first time I connect to a machine via SSH with public/private keys? [duplicate]](https://superuser.com/questions/19563/how-do-i-skip-the-known-host-question-the-first-time-i-connect-to-a-machine-vi)
    - `UserKnownHostsFile=/dev/null`

此选项默认值为yes.

在ssh连接目标服务器时, 如果在`~/.ssh/knows_hosts`文件中, 没有存储目标主机的公钥, ssh客户端会提示接受目标公钥. 

```log
$ ssh root@192.168.166.220
The authenticity of host '192.168.166.220 (192.168.166.220)' can't be established.
RSA key fingerprint is 3c:67:0e:d5:1b:28:30:28:f4:62:15:e4:1d:ea:fb:76.
Are you sure you want to continue connecting (yes/no)? 
```

尤其是如果对方重装过系统, `known_hosts`文件存储的公钥与新公钥不一致时, 会报错而终止.

```log
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
Add correct host key in /app/general/.ssh/known_hosts to get rid of this message.
Offending key in /app/general/.ssh/known_hosts:1260
RSA host key for 192.168.166.220 has changed and you have requested strict checking.
Host key verification failed.
```

将StrictHostKeyChecking设置为`no`后就不会有这种情况.

```log
$ ssh -o 'StrictHostKeyChecking no' root@192.168.166.220
Warning: Permanently added '192.168.166.220' (RSA) to the list of known hosts.
Last login: Sat Dec 30 20:39:42 2017 from 192.168.101.65
[root@220 ~]# 
```

> `StrictHostKeyChecking`选项不是不检查, 而是默认接受对方公钥. 但如果存储的公钥与目标公钥不一致时, 虽然也能正常登录, 但不会更新新的公钥(旧的公钥依然存在).

## `UserKnownHostsFile=/dev/null`

本来以为只要用`StrictHostKeyChecking`就可以了, 但实际上如果`known_hosts`文件中已经存在一个之前的密钥记录(一般出现在多次创建`nat`主机, 并将公网IP解析到同一个域名时), 就算有`StrictHostKeyChecking`配置, 也还是会出错.

```log
$ ssh -o "StrictHostKeyChecking=no" forward-ssh
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@       WARNING: POSSIBLE DNS SPOOFING DETECTED!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
The ECDSA host key for nat.generals.space has changed,
and the key for the corresponding IP address 39.98.41.55
is unknown. This could either mean that
DNS SPOOFING is happening or the IP address for the host
and its host key have changed at the same time.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
SHA256:r9GdAzaDL42cXxumRHUx39Pp3GbMDu66I3espsGtvXE.
Please contact your system administrator.
Add correct host key in C:\\Users\\general/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in C:\\Users\\general/.ssh/known_hosts:1
Password authentication is disabled to avoid man-in-the-middle attacks.
Keyboard-interactive authentication is disabled to avoid man-in-the-middle attacks.
Port forwarding is disabled to avoid man-in-the-middle attacks.
Error: forwarding disabled due to host key check failure
```

只能手动把`known_hosts`文件中发生冲突的密钥信息删除掉...

后来终于找到了参考文章4, 5, 再加一个`UserKnownHostsFile=/dev/null`, 就可以了.
