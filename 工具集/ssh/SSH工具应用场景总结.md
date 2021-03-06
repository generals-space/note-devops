# SSH工具应用场景总结

## 2. 快捷登录

### 2.1 别名

参考文章

[ssh 别名登录小技巧](http://www.ttlsa.com/linux/ssh-config-aliases-server-access-tricks/)

```
$ vim ~/.ssh/config

## Host只是登录别名
Host general
    ## HostName可以是域名也可以是IP
    HostName 12.34.56.78
    Port 22
    User root
    ## 可以决定是否使用密钥登录
    ## IdentityFile ~/.ssh/id_rsa.pub
```

```
## 之后可以以如下方式登录
$ ssh general
...
```

`.ssh/config`文件对应于`/etc/ssh/ssh_config`, 其中的配置也是相同的, 可以查看所有可用选项及选项值.

另外, 对于`.ssh`目录下的文件, 需要保证权限足够小, 最好将其权限设置为`600`, 否则可能会有如下情况发生.

```
$ ssh general
Bad owner or permissions on /home/general/.ssh/config
```

## 5. pem文件概述

在介绍pem文件的来源及使用方法前, 首先要明白一个事实. 那就是, **密钥对不分使用用户**. 意思是, 在root身份下创建一对密钥, 可以将其放在任意用户的`~/.ssh/`目录下. 并且放在哪一个用户目录下, 客户端登陆之后就可以获得哪一个用户的权限.

比如, 在主机A上进行如下操作

```
## 主机A上以root用户创建新的普通用户user1
$ useradd -m /home/user1 user1
## root用户生成一对密钥
$ ssh-keygen -t rsa -f user1
...
$ ls
user1 user1.pub
## 为user1用户创建.ssh目录与authorized_keys文件
$ mkdir /home/user1/.ssh
$ touch /home/user1/.ssh/authorized_keys
## 将生成的公钥文件user1.pub的内容添加到user1的authorized_keys文件中
$ cat user1.pub > /home/user1/.ssh/authorized_keys
```

然后, 在主机B上将上面root用户创建的私钥`user1`文件下载下来, 使用这个私钥的用户身份`user1`登陆A主机. 同样可以实现无密码登陆.

```
$ ssh -i user1 user1@主机A的IP地址
```

------

现在可以体会到 **密钥对** 的涵义了吧. 双方各持有相匹配的公钥与私钥, 就可以完成认证. 持有公钥的一方将作为服务端等待对方登陆, 而持有私钥的一方将获得一个登陆服务端登陆的用户权限, 并且不知道该用户的密码.

说到这里, 我觉得可以把私钥当作`身份证`, 与之对应的公钥为用这个身份证生成的`通行证`, 远程主机上保留有用户A的`通行证`时, 任何持有A身份证的人都可以登陆...有点像冒名顶替, 咳.

pem文件的生成也是如此, `ssh-keygen`时使用`-f`选项指定生成的文件名即可, 其时就是一个简单的私钥文件. 通常将私钥文件下发给用户, 而公钥文件导入服务器, 这样用户就可以以这个私钥的身份登陆了.

```
$ ssh-keygen -t rsa -f user1.pem
$ ls
user1.pem user1.pem.pub
```

## 6. 远程执行命令

```
$ ssh -p 端口号 用户名@远程主机IP '远程命令'或'远程脚本'
```

示例

```
$ ssh root@192.168.1.1 'cat /etc/yum.conf'
```

执行的命令可以是复杂的函数, 并且可以得到远程主机的标准输出, 十分方便.

### 6.1 -n参数, 去除本地标准输入的干扰

参考文章

[ssh命令输入问题（-n选项作用）](http://blog.csdn.net/notsea/article/details/42028359)

在一个shell脚本里嵌入ssh远程执行命令的代码时, 有可能会截取到脚本中传入的标准输入, 对其他操作造成影响.

来看一个例子

```
$ cat test.sh
#!/bin/bash
while read line  
do  
  echo $line  
  ssh root@192.168.1.1 'date'
done << EOF  
1  
2  
3  
4  
5  
EOF
```

我们希望这个脚本每输出一个数字, 就远程执行一次`date`命令, 所以理论上应该有10行输出. 但实际执行时输出如下, 只有两行.

```
$ ./test.sh
1
Fri Sep  9 11:26:18 CST 2016
```

也就是说, while循环只读到1, 就认为到了文件末尾了, 那剩下的几行被谁读取了? 我们猜测是`ssh`, while所需要的标准输入流被传到ssh要执行的命令中去了.

我们验证一下, 将`test.sh`修改成如下

```
#!/bin/bash
while read line  
do  
  echo $line  
  ## ssh root@192.168.1.1 'date'
  ssh root@192.168.1.1 'read a; echo $a; read b; echo $b; read c; echo $c; read d; echo $d; date'
done << EOF  
1  
2  
3  
4  
5  
EOF
```

然后再次执行`test.sh`

```
$ ./test.sh
1
2
3
4
5
Fri Sep  9 11:33:51 CST 2016
```

呐, 我们看到while循环读取的标准输入流全都被`ssh`get到了. 这并不是我们所希望的, 想一想, 如果我们想通过while循环读取IP列表, 结果剩下的列表都被第一行的ssh截获了...

我们尝试一下. 新建一个IP列表文件`ip_list`, `test.sh`从其中读取IP信息并远程执行`date`命令.

```
$ cat ip_list
192.168.1.1
192.168.1.2
192.168.1.3
192.168.1.4
$ cat test.sh
#!/bin/bash
while read IP
do
  echo $IP
  ssh root@$IP 'date'
done < ./ip_list
```

执行它

```
$ ./test.sh
192.168.1.1
Fri Sep  9 11:33:31 CST 2016
```

结果不出所料...

解决方法是, ssh提供的`-n`选项, 专门解决这个问题. 它是将`/dev/null`作为ssh执行命令时的标准输入, 从而屏蔽本地输入.

我们将`test.sh`中ssh命令加上`-n`选项

```
ssh -n root@$IP 'date'
```

再次执行

```
$ ./test.sh
192.168.1.1
Fri Sep  9 11:33:46 CST 2016
192.168.1.2
Fri Sep  9 11:53:33 CST 2016
192.168.1.3
Fri Sep  9 11:33:46 CST 2016
192.168.1.4
Fri Sep  9 11:41:56 CST 2016
```

成功.

## 7. 去除DNS反解

参考文章

1. [SSH登录过慢怎么办？取消ssh的DNS反解](http://www.zxsdw.com/index.php/archives/1078/)

ssh登陆某些服务器,会发生需要等到十来秒才提示输入密码下现象,其实这个是sshd做的一个配置上的修改引起的.

使用的Linux用户可能觉得用SSH登陆时为什么反映这么慢, 有的可能要几十秒才能登陆进系统. 其实这是由于默认sshd服务开启了DNS反向解析, 如果你的sshd没有使用域名等来作为限定时, 可以取消此功能. 

编辑`/etc/ssh/sshd_config`文件, 将 `# UseDNS yes`改为`UseDNS no`(没有的话自行添加)然后重启sshd服务即可.