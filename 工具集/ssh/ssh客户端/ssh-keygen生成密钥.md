# ssh-keygen生成密钥

使用`ssh-keygen`命令创建`rsa`方式认证的密钥.

```
[general@general ~]$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/general/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/general/.ssh/id_rsa.
Your public key has been saved in /home/general/.ssh/id_rsa.pub.
The key fingerprint is:
81:0e:76:d3:bc:b0:2b:7f:cf:99:ce:32:84:0c:41:41 general@general
The key's randomart image is:
+--[ RSA 2048]----+
|   oE.           |
|    .  +         |
|    o.= +        |
|   ..+ + o       |
|     oo.S        |
|      o..        |
|    . ..         |
|     o  +o o     |
|      .. =B      |

```

这样, 就会在`~/.ssh`目录下创建`id_rsa(私钥)`与`id_rsa.pub(公钥)`两个文件.

## 选项详解

`-f`选项可以生成指定名称的密钥文件

```
$ ssh-keygen -t rsa -f general.pem
...
$ ls
general.pem general.pem.pub
```

`-C`选项可以生成指定注释(就是公钥尾部那串`general@general`)的密钥文件, 可以随便填写的, 不过最好填有意义, 易识别的名称, 方便在远程服务器上查看各有哪些用户导入了公钥.

```
ssh-keygen -t rsa -C '任意名称@任意IP'
```
