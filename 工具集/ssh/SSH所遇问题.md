# SSH所遇问题

## 1.

[ssh-copy-id出错: "No such file"](http://www.jianshu.com/p/848e982df6be)

```
/usr/bin/ssh-copy-id: ERROR: failed to open ID file './id_rsa': No such file or directory
```

ssh-copy-id命令可以将指定公钥添加到远程机器的authorized_keys中, 从而实现SSH无密码登录.

在执行`ssh-copy-id`命令时, 可能会出现如下错误

```
$ ssh-copy-id -i id_rsa.pub root@192.168.169.115
/usr/bin/ssh-copy-id: ERROR: failed to open ID file './id_rsa': No such file or directory
```

原因分析:

`ssh-copy-id`命令执行时会检测公钥`id_rsa.pub`目录下是否同时存在对应的私钥`id_rsa`文件. 如果不存在, 则会报错.

解决办法:

在`id_rsa.pub`文件所在目录创建一个`id_rsa`空文件即可.

## 2. 

```shell
$ ssh 用户名@ip地址
ssh_exchange_identification: read: Connection reset by peer
```

情境描述: ssh方式登陆, 输入密码后被拒绝

可能原因: 防火墙, hosts.deny都有可能是阻止的原因, 这种情况下一般不是验证本身的问题.

## 3. XShell ssh服务器拒绝了密码 请再试一次

问题描述: XShell连接虚拟机的ssh, 显示"ssh服务器拒绝了密码 请再试一次", 一直让输入密码.

原因分析: 可能在`/etc/ssh/sshd_config`中存在这样一句:

```
# Authentication:
LoginGraceTime 120
# PermitRootLogin without-password  ##注意, 这行是重点, 需要注释掉!!!
StrictModes yes
```

解决方法: 将`without-password`这行注释掉即可