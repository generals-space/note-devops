# ansible问题处理

## 1. 

```
fatal: [172.17.0.3]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: Control socket connect(/root/.ansible/cp/ansible-ssh-172.17.0.3-22-root): Connection refused\r\nFailed to connect to new control master\r\n", "unreachable": true}
```

问题分析

这种情况一般出现在使用docker作为ansible容器的时候. 

ssh客户端可以配置`ControlPath`字段启用"缓存", 它会在与远程主机建立连接后生成一个`sock`类型的文件, 之后的ssh连接可以通过这个文件与远程主机通过, 具体请参考ssh命令应用. 但是, 存储在docker容器中的`sock`文件貌似是无法使用的, 原因应该是docker存储驱动的问题, 将其存储在`-v`挂载的主机目录中就不会有这种问题, 出现在`docker-1.14-rc2`的源码安装版本.

解决方法

因为ansible在通过ssh工具连接远程主机时, 自行加上了许多参数, 用于重用/加速连接, 只要将这些参数去掉即可. ansible配置文件在`/etc/ansible/ansible.cfg`, 把`ssh_args`赋值为空就好了.

## 2. 

参考文章

[ansible小结（四）ansible.cfg与默认配置](http://www.361way.com/ansible-cfg/4401.html)

```
Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this
```

详细报错为

```
192.168.1.1 | FAILED => Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host.
192.168.1.2 | FAILED => Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host.
```

问题描述

不使用SSH私钥, 而是在inventory清单文件中以变量形式写入密码, 格式如下. 但是在执行playbook时报上述错误

```
[target]
192.168.1.1 ansible_ssh_user=root ansible_ssh_pass=123456
192.168.1.2 ansible_ssh_user=root ansible_ssh_pass=123456
```

原因分析

这是因为首次连接远程主机时, ssh会提示将远程主机的fingerprint key串加到本地的`~/.ssh/known_hosts`文件中. 就是如下部分这种啦, 眼熟吧?

```
The authenticity of host '106.75.5.133 (106.75.5.133)' can't be established.
RSA key fingerprint is c1:a1:8b:9f:30:dc:2b:6d:a7:75:e5:67:60:26:ff:d1.
Are you sure you want to continue connecting (yes/no)?
```

ansible的执行过程会被这种提示打断, 所以提示出错.

解决方法

方法1：

了解到问题原因为, 我们了解到进行ssh连接时, 可以使用-o参数将StrictHostKeyChecking设置为no, 使用ssh连接时避免首次连接时让输入yes/no部分的提示.通过查看ansible.cfg配置文件, 发现如下行：

```
[ssh_connection]
# ssh arguments to use
# Leaving off ControlPersist will result in poor performance, so use
# paramiko on older platforms rather than removing it
#ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

所以这里我们可以启用`ssh_args`部分, 使用下面的配置, 避免上面出现的错误：

```
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking＝no 
```

方法2：

在`ansible.cfg`配置文件中, 也会找到如下部分：

```
# uncomment this to disable SSH key host checking
host_key_checking = False  
```

默认`host_key_checking`部分是注释的, 通过找开该行的注释, 同样也可以实现跳过ssh首次连接提示验证部分. 由于配置文件中直接有该选项, 所以推荐用方法2.