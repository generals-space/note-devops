# ip tunnel添加设备失败-File exists

参考文章

1. [Debian Bug report logs - #508450 ip tun add fails to create tunnel without remote, though no error](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=508450)
2. [File exists error seen while adding tunnel device](https://github.com/projectcalico/felix/issues/928)
3. [Retry IPIP configuration on failure. ](https://github.com/projectcalico/felix/pull/953)
    - 修复了参考文章2中的issue

在linux下做模拟calico网络的隧道实验时, 添加`tunnel`设备失败, 显示报错如下.

```log
$ ip tunnel add tun_gre0 mode gre
add tunnel "gre0" failed: File exists
```

网上查了查, 参考文章1中说到, `The remote argument is not always required, ie. when you specily local a.b.c.d (and leave remote as any)`.

意思是, 在创建新的`tunnel`设备时, `remote`参数可能不是必需的, 但是`local`参数一定要填.

其实`tunnel`设备一般用于点对点的隧道式通信, 常规的使用方法如下命令.

```
ip tunnel add tun_gre0 mode gre remote 8.210.37.47 local 172.16.156.195
ip link set tun_gre0 up
ip addr add 192.168.1.1 peer 192.168.1.2 dev tun_gre0
ip r add 172.31.240.0/20 dev tun_gre0
```

我们可以把`remote`参数移除, 只保留`local`, 但是如果两个都没有的话, 就会出现`File exists`错误了.

------

参考文章2是calico官方组件`felix`的issue, ta们也出现了这个问题.

```
FailedSystemCall: Failed system call (retcode : 1, args : ('ip', 'tunnel', 'add', 'tunl0', 'mode', 'ipip'))
  stdout  : 
  stderr  : ip: ioctl 0x89f1 failed: File exists

  input  : None
```

不过可疑的是, 在修改这个bug的`pull request`(参考文章3)中, 并没有提及`local`参数的问题, 貌似就真的失败时重试了一下...

不知道ta们是怎么搞定的...
