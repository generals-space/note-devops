# Linux平台下LDAP服务器搭建(一)-基础篇

参考文章

[开源跳板机(堡垒机)Jumpserver v2.0.0 部署篇](http://laoguang.blog.51cto.com/6013350/1636273)

[linux杂谈（十一）:LDAP服务器的搭建](http://www.2cto.com/os/201404/296572.html)

[Centos下构建LDAP服务](http://www.centoscn.com/image-text/config/2013/0819/1367.html)

## 1. 实验环境

1. LDAP服务器A, CentOS6.7 172.32.100.120

2. LDAP客户端B, CentOS6.7 172.32.100.140

3. 测试机C, ...系统随便, 能用就行

**注意, 先将这几台机器的防火墙和SELinux关了.**

```shell
service iptables stop
setenforce 0
```

## 2. 服务端配置

### 2.1 首先安装LDAP软件包

```shell
yum install openldap*
```

### 2.2 拷贝配置文件到指定目录

```shell
cp /usr/share/openldap-servers/slapd.conf.obsolete /etc/openldap/slapd.conf
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
```

### 2.3 编辑slapd配置文件

```
# vim /etc/openldap/slapd.conf
...
#######################################################################
# database definitions
#######################################################################
database        bdb
suffix          "dc=generals,dc=space"
checkpoint      1024 15
rootdn          "cn=general,dc=generals,dc=space"
rootpw          123456

...
```

其中

- suffix: 其实就是BaseDN(先不要管什么是`BaseDN`)

- rootdn: 超级管理员的dn(`cn`值默认为`Manager`, 也可以改成`admin`或`root`这样, `general`是我自己的名称, 就是可能不大容易理解)

- rootpw: 超级管理员的密码, 这里暂时用明文

> 注意：rootpw一定要在这行的开头, 否则不生效. 并且, 这些字段之间不存在空格, 全都是通过`tab`键隔开的.

### 2.4 启动slapd服务

查看启动情况, 第一次启动生会初始化ldap数据库, 在`/var/lib/ldap`中, 如果想删除ldap数据库就删除该目录, 保留`DB_CONFIG`配置文件.

```shell
$ service slapd start
Starting slapd:                                            [  OK  ]
```

ldap实际使用的是`/etc/openldap/slapd.d/` 下的配置文件, `/etc/openldap/slapd.conf`只是生成配置文件的模板. 删除原来的配置文件, `slaptest`重新生成新的配置文件.

```shell
$ rm -rf /etc/openldap/slapd.d/*
$ slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
config file testing succeeded
$ chown -R ldap:ldap /etc/openldap/slapd.d/
$ service slapd restart
$ netstat -tulnp | grep slapd
```

> slapd服务默认监听389端口

### 2.5 创建ldap合法帐户

```shell
$ useradd ldapuser1
$ passwd ldapuser1
```

这些用户仅仅是系统上存在的用户(存储在`/etc/passwd`和`/etc/shadow`中), 并没有在**LDAP数据库**里, 所以要把这些用户导入到LDAP里面去. 但LDAP只能识别特定格式的文件 即后缀为ldif的文件(也是文本文件), 所以不能直接使用`/etc/passwd`和`/etc/shadow`文件. 需要借助`migrationtools`这个工具把这两个文件中的内容转变成LDAP能识别的格式.

```shell
# 安装配置migrationtools
$ yum install migrationtools -y
# 进入migrationtool配置目录
$ cd /usr/share/migrationtools/
```

修改该目录下的`migrate_common.ph`文件, 将其中的如下部分

```
# Default DNS domain
$DEFAULT_MAIL_DOMAIN = "padl.com";

# Default base
$DEFAULT_BASE = "dc=padl,dc=com";
```

修改为

```
# Default DNS domain
$DEFAULT_MAIL_DOMAIN = "generals.space";

# Default base
$DEFAULT_BASE = "dc=generals,dc=space";
```

与`slapd.conf`文件中的配置相对应即可.

------

然后通过`migrationtools`将`/etc/passwd`与`/etc/group`文件中的内容转换成`ldap`需要的文件.

首先提取想要映射的账号

```shell
$ pwd
/usr/share/migrationtools
grep 'ldapuser1' /etc/passwd > /tmp/passwd
grep 'ldapuser1' /etc/group > /tmp/group
```

开始转换

```shell
/usr/share/migrationtools/migrate_base.pl > /tmp/base.ldif
/usr/share/migrationtools/migrate_passwd.pl /tmp/passwd > /tmp/passwd.ldif
/usr/share/migrationtools/migrate_group.pl /tmp/group > /tmp/group.ldif
```

接下来将有效的`ldap`账号文件导入到`ldap`数据库. 这里会提示输入`ldap`的密码, 即是`slapd.conf`文件中的`rootpw`字段的值. 如果是第一次试验, 请保证`passwd.ldif`先于`group.ldif`导入.

```shell
$ ldapadd -x -W -D "cn=general,dc=generals,dc=space" -f /tmp/base.ldif
$ ldapadd -x -W -D "cn=general,dc=generals,dc=space" -f /tmp/passwd.ldif
$ ldapadd -x -W -D "cn=general,dc=generals,dc=space" -f /tmp/group.ldif
```

------

到此, ldap服务端就配置完成了.

## 3. 客户端配置

### 3.1 安装相应软件包

```shell
yum -y install openldap-clients nss-pam-ldapd pam_ldap
```

> 如果没有authconfig系列命令的话(比如精简版的服务器镜像, docker容器环境), 需要手动安装, `yum install authconfig`

### 3.2 配置ldap服务器地址

执行`authconfig-tui`命令(依赖`authconfig*`包, 不过一般linux发行版都会默认安装)

在弹出的第一个窗口`Authentication Configuration`中选择

- 左侧: `Use LDAP`

- 右侧: `Use Shadow Passwords`, `Use LDAP Authentication`与`Local authorization is sufficient`

选择next, 出现`LDAP Settings`窗口

- 暂不勾选`Use TLS`选项

- Server字段填写ldap服务器地址, 按照输入框中的格式即可

- Base DN的取值也很明了, 与`slapd.conf`文件中对应即可.

点击ok, 客户端会自行启动一个`nslcd`的服务. (说明docker镜像中只有第一次安装`authconfig*`包时会启动此服务, 并且没有办法使用`service`命令手动启动, 暂时无解)

## 4. 测试

首先, 在客户端使用`su`命令切换用户, 如果切换成功, 说明ldap服务器正常工作. 注意此时客户端是不存在`ldapuser1`这个用户的.

```shell
su ldapuser
```

然后, 在测试机C上通过`ssh`以`ldapuser1`用户身份登录客户机.

```shell
ssh ldapuser1@172.32.100.140
```


su权限管理

------

## FAQ

### 1.

如果在测试ssh登录客户机时出现登录失败, 提示

```
general@172.32.100.140's password:
Permission denied, please try again.
general@172.32.100.140's password:
```


查看客户机的登录日志`/var/log/secure`

```
Jul 11 01:07:42 localhost sshd[2621]: Accepted password for ldapuser1 from 172.32.100.1 port 61433 ssh2
Jul 11 01:07:43 localhost sshd[2621]: pam_unix(sshd:session): session opened for user ldapuser1 by (uid=0)
Jul 11 01:07:59 localhost sshd[2625]: Received disconnect from 172.32.100.1: 0:
Jul 11 01:07:59 localhost sshd[2621]: pam_unix(sshd:session): session closed for user ldapuser1
Jul 11 01:08:04 localhost unix_chkpwd[2647]: password check failed for user (ldapuser1)
Jul 11 01:08:04 localhost sshd[2645]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=172.32.100.1  user=ldapuser1
Jul 11 01:08:04 localhost sshd[2645]: pam_ldap: error trying to bind as user "uid=ldapuser1,ou=People,dc=generals,dc=space" (Invalid credentials)
Jul 11 01:08:05 localhost sshd[2645]: Failed password for ldapuser1 from 172.32.100.1 port 61435 ssh2
```

从`uid=ldapuser1,ou=People,dc=generals,dc=space`来看, 用户名在ldap服务器上的确是合法用户, 但未通过认证.

请确认在服务器创建`ldapuser1`系统用户并且在将其转换为ldap用户之前为其指定了密码(通过`passwd`命令).

因为ssh默认不支持空密码登录, 若最初始未指定密码, 是无法以该用户身份通过空密码登录的. 并且系统用户与ldap用户并不相关, 将系统用户转换为ldap用户之后再用`passwd`修改`ldapuser1`的密码是无效的(当然, 以该身份登录ldap服务器本身是可以的), ldap数据库中的用户密码并未改变.

修改ldap用户密码的命令请参考第二篇文章.

### 2.

[authconfig-tui ImportError: No module named acutil](http://www.chenxie.net/archives/521.html)

手动安装了新版本的python(这里是2.7.13)后, 启动`authconfig-tui`时报错如下:

```py
Traceback (most recent call last):
  File "/usr/sbin/authconfig-tui", line 28, in <module>
    import authinfo, acutil
  File "/usr/share/authconfig/authinfo.py", line 36, in <module>
    import dnsclient
  File "/usr/share/authconfig/dnsclient.py", line 23, in <module>
    import acutil
ImportError: No module named acutil
```

无论是yum还是pip都没有找到名为`acutil`的包. 而原来使用系统自带的python(版本为2.6.6)就没有出现此错误.

解决方法:

`authconfig-tui`也是一个python脚本, 同yum一样, 依赖于python2.6. 所以与yum的兼容方法一样, 将其第一行的python的声明改为指向2.6版本的即可

```py
#!/usr/bin/python2.6
```

### 3. 关于nslcd服务无法启动的问题

客户端安装nslcd服务并成功登陆ldap服务器后, 重启, nslcd处于关闭状态, 使用`service nslcd start`无法启动. 执行`/etc/init.d/nslcd start`也不行.

...不过`servicef nslcd restart`可以...害我新建/删除了好几个docker容器
