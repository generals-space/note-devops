# FTP服务器配置-访客模式(guest)

> 访客模式在网上普遍被称作ftp的`虚拟用户`方式. 基本原理就是, 在ftp服务器上创建一个用户A, 然后`vsftpd`服务以这个A用户的身份创建任意个虚拟用户(这些虚拟用户只对`vsftpd`服务有效, 实际上并不存在于系统中), 虚拟用户所拥有的权限至多为A的权限, 并且可以为这些虚拟用户单独设置其各自的ftp目录, 读写权限, 会话失效时间, 文件传输速率等等. 所以这种方式搭建的ftp服务器使用方便, 且非常安全.

首先, **关闭防火墙与SELinux**.

然后安装`vsftpd`

```
$ yum -y install vsftpd*  db4-*
```

建立vsftp虚拟宿主用户，虚拟用户并不是系统用户，在系统中是不存在的，但它们需要一个实际的系统用户作为宿主用户。可以将其设置为`nologin`的登陆模式, 不创建用户目录.

```
$ useradd ftpuser -s /sbin/nologin
```

## 1. 配置文件理解

接下来开始配置vsftp. 通过yum安装的vsftpd服务, 配置文件默认在`/etc/vsftpd`目录下.

```
$ pwd
/etc/vsftpd
$ ls
ftpusers  user_list  vsftpd.conf  vsftpd_conf_migrate.sh
```

其中, `ftpusers`与`user_list`中都为系统用户列表, 不同的是, `ftpusers`文件中列出的是绝对禁止通过ftp方式登陆的系统用户; 而`user_list`中的用户, 需要根据`vsftpd.conf`文件中的`userlist_deny={YES|NO}`字段判断. 其值取`YES`时, 只有该文件列出的用户允许通过ftp登陆, 取`NO`时, 该文件中的用户连同`ftpusers`中列出的用户都将被禁止.

而`vsftpd.conf`为`vsftpd`服务的主配置文件.

## 2. 创建虚拟用户

我们先新建一个虚拟用户列表文件`virusers`, 在这个列表中的用户是允许ftp登陆的合法用户. 其格式为`一行用户名, 一行密码`. 如下

```
$ pwd
/etc/vsftpd
$ cat viruser
ftpuser1
123456
general
123456
```

然后执行`db_load -T -t hash -f /etc/vsftpd/virusers /etc/vsftpd/virusers.db`, 这将会以`virusers`文件为准生成一个`virusers.db`文件, 用于ftp的登陆验证.

然后编辑`/etc/pam.d/vsftpd`, **将其中原来的内容注释掉或删除**, 添加如下几行

```
auth sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/virusers
account sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/virusers
```

一般64位系统为`/lib64/security/pam_userdb.so`, 而32位系统为`/lib/security/pam_userdb.so`. 

另外, `db=/etc/vsftpd/virusers`中`virusers`并不是指`db=/etc/vsftpd/virusers`文件本身, 而是 **名为`virusers`并且后缀为`.db`的文件**.

注意: ftp虚拟用户登陆验证的实际文件不是`virusers`, 而之后也可以将此文件删除或限制其读权限, 以免其中明文存储的用户名密码被窃取.

------

然后为虚拟用户创建各自的配置文件及ftp主目录, 以`general`这个虚拟用户为例.

```
## 用以存储虚拟用户的配置文件
$ mkdir /etc/vsftpd/viruser.d
## 虚拟用户配置文件名需要与用户名相同, 而且不可以加任何后缀!!!
$ touch /etc/vsftpd/viruser.d/general
## 虚拟用户general的ftp主目录, 需要将权限赋予ftp宿主用户`ftpuser`
$ mkdir -p /opt/vsftpd/general
$ chown -R ftpuser:ftpuser /opt/vsftpd
```

## 3. 配置虚拟用户

首先, 在`/etc/vsftpd/vsftpd.conf`文件中添加如下语句

```
## vsftpd服务的验证将通过PAM模块.
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES

## 设定启用虚拟用户功能
guest_enable=YES
## 虚拟用户的配置目录
user_config_dir=/etc/vsftpd/viruser.d
## 指定虚拟用户的宿主用户, 就是我们开始时创建的`ftpuser`
guest_username=ftpuser
## 设定虚拟用户的权限符合他们的宿主用户, 这一句也很重要!!!
virtual_use_local_privs=YES
```

然后编辑`/etc/vsftpd/viruser.d/general`, 添加

```
## 如果不添加这一行, 则用户的主目录为其ftp的宿主用户家目录
local_root=/opt/vsftpd/general
```

启动`vsftpd`服务.

```
service vsfptd start
```

## 4. 测试ftp登陆

在客户端上通过ftp尝试登陆.

```
$ ftp
ftp> open 172.17.0.4
Connected to 172.17.0.4 (172.17.0.4).
220 (vsFTPd 2.2.2)
Name (172.17.0.4:general): general
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
227 Entering Passive Mode (172,17,0,4,116,226).
150 Here comes the directory listing.
226 Directory send OK.
ftp> mkdir first
257 "/opt/vsftpd/general/first" created
ftp> quit
221 Goodbye.
```

到ftp服务端`/opt/vsfptd/general`下查看, 会发现测试登陆时创建的`first`目录的所属用户为`ftpuser`, 正是我们创建的ftp服务的宿主用户. 这也是`虚拟`用户的涵义所在.

------

## 5. 扩展

以下是一些灵活的权限控制, 分别在`/etc/vsftpd/vsftpd.conf`与`/etc/vsftpd/viruser.d/*`下的配置文件中有效(注意: `viruser.d`这个目录不是一定的, 而是通过`/etc/vsftpd.conf`中`user_config_dir`字段指定的), 不过前者中是全局性的, 后者中是单独对某一虚拟用户起作用的, 有些配置后者可以覆盖前者.

### 5.1 用户访问目录限制

限制虚拟用户只能在其主目录中操作, 用户可以去其他比如`/etc`等目录, 很危险.

要达到这个目的, 需要使用如下三个选项

```
# 取YES时将所有本地用户限制在自家目录中，NO则不限制
chroot_local_user=YES
## 是否允许vsftpd读取一个提供了用户名的文件, 来确定某些例外于chroot_local_user规则的用户
## 如果chroot_local_user指令是YES, chroot_list_enable取YES可以让chroot_list_file指定的文件中列出的用户不受自家目录的限制
## 如果chroot_local_user指令是NO, chroot_list_enable取YES可以让chroot_list_file指定的文件中列出的指定用户被限制
## 就是说chroot_list_file文件中列出的总是chroot_local_user情况的例外用户.
## ...chroot_list_enable为NO? 就跟没有一样啦
chroot_list_enable=YES
## 就是chroot_list_enable取YES时需要读取的文件
chroot_list_file=/etc/vsftpd/chroot_list
```

> 这三个选项需要在vsftp主文件中配置

`chroot_list`文件可以写入被限制用户的用户名, 如下.

```
ftpuser1
general
```

mmp, 如果目录限制的配置总是不生效, 退出ftp客户端再试试, 不只是`close`关掉连接, 而是用`quit`退出...

### 5.2 命令限制

`cmds_allowed`字段可以限制客户端可以执行的命令, 在`/etc/vsftpd/vsftpd.conf`与`/etc/vsftpd/viruser.d/*`文件中都有效, 但以前者为准. 其格式为

```
cmds_allowed=FEAT,REST,CWD,LIST,MDTM,NLST,PASS,PASV,PORT,PWD,QUIT,RETR,SIZE,STOR,TYPE,USER,ACCT,APPE,CDUP,HELP,MODE,NOOP,REIN,STAT,STOU,STRU,SYST,MKD
```

注意: 不能又空格和换行, 另外命令名称必须为大写, 小写的命令将被拒绝执行. 只有显式的指定的命令允许被执行, 未列出的将被拒绝.

```
# ABOR - abort a file transfer 取消文件传输
# CWD - change working directory 更改目录
# DELE - delete a remote file 删除文件
# LIST - list remote files 列出目录内容
# MDTM - return the modification time of a file 返回文件的更新时间
# MKD - make a remote directory 新建文件夹
# NLST - name list of remote directory
# PASS - send password
# PASV - enter passive mode
# PORT - open a data port 打开一个传输端口
# PWD - print working directory 显示当前工作目录
# QUIT - terminate the connection 退出
# RETR - retrieve a remote file 下载文件
# RMD - remove a remote directory
# RNFR - rename from
# RNTO - rename to
# SITE - site-specific commands
# SIZE - return the size of a file 返回文件大小
# STOR - store a file on the remote host 上传文件
# TYPE - set transfer type
# USER - send username

# less common commands:
# ACCT* - send account information
# APPE - append to a remote file
# CDUP - CWD to the parent of the current directory
# HELP - return help on using the server
# MODE - set transfer mode
# NOOP - do nothing
# REIN* - reinitialize the connection
# STAT - return server status
# STOU - store a file uniquely
# STRU - set file transfer structure
# SYST - return system type
```


## FAQ

### 1. 

```
ftp> open 192.168.169.75
Connected to 192.168.169.75 (192.168.169.75).
220 (vsFTPd 2.2.2)
Name (192.168.169.75:root): locals3
331 Please specify the password.
Password:
500 OOPS: cannot change directory:/home/ftpuser
```

貌似必须要为ftp虚拟用户的宿主用户创建一个home目录, 即使是nologin形式的用户, 不然登录的时候会报上述错误.