# Linux Bash应用技巧.2.实践

参考文章

1. [像黑客一样使用Linux命令行](https://talk.linuxtoy.org/using-cli/#1)
    - 在线PPT
2. [学习T神的《像黑客一样使用Linux命令行》](https://zlotus.github.io/2014/07/07/using-cli-like-a-hacker/)

## 1. 初级

### 2.1

删除上一条命令中的多余部分

```log
$ grep fooo /var/log/auth.log
$ ^o
$ grep foo /var/log/auth.log
```

替换输错的部分

```log
$ ansible nginx -m command -a 'which nginx'
$ !:gs/nginx/squid
$ ansible squid -m command -a 'which squid'
```

### 2.2 

重复上一条命令

```log
$ apt-get install figlet
E: Could not open lock file /var/lib/dpkg/lock - open (13: Permission denied)
E: Unable to lock the administration directory (/var/lib/dpkg/), are you root?

$ sudo !!
sudo apt-get install figlet
```

### 2.3

选取上一条命令中的第一个参数

```log
$ ls /usr/share/doc /usr/share/man

$ cd !^
```

### 2.4

选取参数中路径的开头部分

```log
$ ls /usr/share/fonts/truetype

$ cd !$:h
cd /usr/share/fonts
```

## 2. 进阶

组合使用命令选取与参数选取

```log
[root@localhost nginx]# ls /var/log/nginx/
access.log  access.log-20160331.gz  error.log  error.log-20160331.gz
[root@localhost nginx]# pwd
/etc/nginx
[root@localhost nginx]# cd !-2:1
cd /var/log/nginx/
[root@localhost nginx]#
```

```log
[root@localhost nginx]# cd /var/log/nginx
[root@localhost nginx]# cd !cd:1:h
cd /var/log
```

不过`!?string`貌似无法与参数选取合用

```log
[root@localhost log]# cd /var/log/nginx
[root@localhost nginx]# cd /etc/nginx/
[root@localhost nginx]# cd !?var:1:h
-bash: !?var:1:h: event not found
```
