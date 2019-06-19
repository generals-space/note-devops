---
title: FTP问题处理
---

## 1. 500

```
ftp> open 192.168.100.147
Connected to 192.168.100.147.
220 Welcom to my FTP server.
530 Please login with USER and PASS.
530 Please login with USER and PASS.
KERBEROS_V4 rejected as an authentication type
Name (192.168.100.147:jiale.huang): automopote
331 Please specify the password.
Password:
500 OOPS: cannot locate user entry:automopote
Login failed.
```

一般是由于ftp使用虚拟用户模式, 但并未正常配置虚拟用户的选项.

首先要保证`vsftpd.conf`文件中有如下语句以开启虚拟用户模式.

```
guest_enable=YES
guest_username=ftpuser
```

然后保证系统中存在此`ftpuser`用户与同名组, 并为将ftp根目录的用户属主与组修改为此用户.