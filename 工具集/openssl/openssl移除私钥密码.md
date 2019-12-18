# openssl移除私钥密码

参考文章

1. [SSH私钥取消密码](http://www.au92.com/archives/remove-passphrase-password-from-private-rsa-key.html)

如果在创建密钥时, 在`Enter passphrase (empty for no passphrase):`与`Enter same passphrase again:`两句处输入了密码, 那就算使用了密钥登录方式, 交换公钥到对方主机, 使用`ssh`登录该主机时, 还要输入你自己的私钥密码.

```[general@general .ssh]$ ssh root@192.168.166.220
Enter passphrase for key '/app/general/.ssh/id_rsa':
Last login: Sat Jul 23 17:58:27 2016 from 10.96.0.71
```

如果将此密钥对应的公钥拷贝到了很多主机上, 又需要经常登录大量主机, 每次登录时需要输入密码, 可能会觉得麻烦. 希望使用没有密码的密钥, 但是不能任性地再次生成新密钥, 否则之前拷贝到其他主机上的公钥认证就无效了. 解决方法是, 去除当前私钥上的密码. 这样原有的公钥认证 **依然有效**, 可以在其他之前的主机的时候不再输入私钥密码. 操作如下.

```
## 使用openssl命令去掉私钥的密码
$ openssl rsa -in ~/.ssh/id_rsa -out ~/.ssh/id_rsa_new
## 备份旧私钥
$ mv ~/.ssh/id_rsa ~/.ssh/id_rsa.backup
## 使用新私钥
$ mv ~/.ssh/id_rsa_new ~/.ssh/id_rsa
## 设置权限
$ chomd 600 ~/.ssh/id_rsa
```

再次使用`ssh`登录, 将不再需要密钥密码.

> 同理也可去除dsa加密的密钥密码.
