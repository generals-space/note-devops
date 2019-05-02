# Rsync服务理解与基本使用

## 1. Rsync工作模式

Linux下man手册对于rsync命令的参数解释如下

```
Local:  rsync [OPTION...] SRC... [DEST]

Access via remote shell:
  Pull: rsync [OPTION...] [USER@]HOST:SRC... [DEST]
  Push: rsync [OPTION...] SRC... [USER@]HOST:DEST

Access via rsync daemon:
  Pull: rsync [OPTION...] [USER@]HOST::SRC... [DEST]
        rsync [OPTION...] rsync://[USER@]HOST[:PORT]/SRC... [DEST]
  Push: rsync [OPTION...] SRC... [USER@]HOST::DEST
        rsync [OPTION...] SRC... rsync://[USER@]HOST[:PORT]/DEST
```

不算Local所表示的本地同步外(本地备份尽可以用cp, tar来完成, 没什么意义), rsync有两种工作模式:

**1. shell模式: 使用远程shell程序(如ssh)进行连接.**

当源路径或目的路径的主机名后面包含一个冒号分隔符时使用这种模式.  rsync安装完成后就可以直接使用了, 无所谓启动服务与否.

**2. daemon模式: 使用TCP直接连接rsync daemon.**

当源路径或目的路径的主机名后面包含两个冒号, 或使用rsync://URL时使用这种模式, 说明连接使用的是rsync自己定义的协议, 无需远程shell. 但必须在其中一台机器上启动rsync守护进程, 默认端口873. 

rsync可以通过`rsync --daemon`使用独立进程的方式开启守护进程, 或者通过`xinetd`超级进程来管理`rsync`后台进程.

**首先关闭双方的防火墙与SELinux.**

### 1.1 shell模式

这种方式采用SSH方式进行工作, 传输的口令及文档内容全部是加密数据. 远程账号(下例中的general)是远程服务器实体账户, 口令也是此实体账户的系统口令, 与scp十分相似.

```
rsync -avzP /home/general/Documents general@172.16.171.132:~/Public/
general@172.16.171.132's password:

rsync -avzP /home/general/Documents/ general@172.16.171.132:~/Public/
general@172.16.171.132's password:
```

注意:

第一条命令是把本地`/home/general/Documents`这个目录同步到远程general用户home目录的/Public目录下;

第二条命令是把本地`/home/general/Documents`目录下的内容同步到远程general用户home目录的/Public目录下(即`/home/general/Public`中不会有Documents这个目录而是直接存放Documents下的内容.

是不是和scp很像?

### 1.2 daemon模式(先不要启动, 服务端还需要一些配置文件, 在下面介绍)

启动rsync服务的两种方式:

#### 1.2.1 --daemon参数方式，是让rsync直接以服务模式运行

```shell
# --config用于指定rsyncd.conf的位置, 默认为/etc/rsyncd.conf
$ /usr/bin/rsync --daemon --config=/etc/rsyncd/rsyncd.conf 　
```

#### 1.2.2 xinetd方式(如果没有这个服务可以先安装)

主要是要打开`xinetd`这个daemon, 一旦有rsync client要连接时, xinetd会把它转交给rsyncd(port 873).

vim编辑/etc/xinet.d/rsync(如不存在可手动创建):

```
# default: off
# description: The rsync server is a good addition to an ftp server, as it 
#       allows crc checksumming etc.
service rsync
{
        disable = no    #如果该文件存在, 则默认disable的值为yes, 将其改为no即可启用
        flags           = IPv6
        socket_type     = stream
        wait            = no
        user            = root
        server          = /usr/bin/rsync
        server_args     = --daemon
        log_on_failure  += USERID
}
```

然后`service xinetd restart`, 使上述设定生效.

## 2. Rsync备份服务器搭建

### 2.1 明确概念:

我们现在将开启rsync服务的主机称为**服务端**, 其他称为**客户端**. 但是这与'本地', '远程'的区别是不同的, 前两者的地位是固定的, **是否为服务端只取绝与rsync服务的开启**, 而后两者, 则是是看你的shell是运行在哪个主机上了;

客户端可以发起rsync备份请求, 向服务器推送或是从服务器取回, 但**服务端无法主动发起请求, 即无法在服务端运行rsync命令连接到客户端**(因为没法验证, 除非客户端也开启rsync服务, 那它也将成为服务端了).

服务端的配置文件将指定一个目录的路径, 此路径要么作为存储来自客户端的需要备份的文件, 要么将其存储到客户端, 二选其一(呐, shell模式就没有这样的限制, 你可以随意指定本地和远程目录).

### 2.2 具体配置

上面说到的rsync的daemon模式, 需要双方其中之一开启了rsync服务(服务端).

这一服务的开启需要服务端两个配置文件:`/etc/rsyncd.conf`, `/etc/rsyncd.secrets`:

- 前者指定了服务的端口, 授权用户, 日志位置, 和**连接名称, 处理连接的用户名(这个用户必须真实存在于服务端哦)**等信息;

- 后者指定了可以使用此服务的用户名及密码(用户名是上面标红的那个哦, 密码只是与客户端的验证约定, 就不要与系统密码相同了, 为了安全), 作为对客户端请求的验证(这个文件名应该是可以随意取的, 可在前者中指定);

另外, 客户端也需要一个配置文件: `/etc/rsync_client.pwd`

这里指定了客户端发起rsync请求的密码.(其实这个文件名也是可以随意取的)

发起请求时(只可能是客户端哦), 需要指定连接名称, 和客户端的密码文件, 到时就需要服务端在配置文件中查询该连接, 和相应的用户名, 然后验证在对应客户端指定的密码是否一致...就可以了. 然后就能推送或拉取数据文件了.

服务端`/etc/rsyncd.conf`(**注意同一行中不要有#注释**):

```
#以root用户启动此服务
uid=root                          
gid=root
use chroot=no
max connections=10
timeout=600
strict modes=yes
#监听873端口
port=873
pid file=/var/run/rsyncd.pid
lock file=/var/run/rsyncd.lock
log file=/var/log/rsyncd.log

# 这是一个目标块, 可以设置多个, 为多个用户设置不同的备份目标
[checksync]
#将来自客户端的需要备份的文件存储到此处,或者将这个目录下的文件备份到客户端(注意:这个路径必须存在且下面的auth users必须对其有相应权限)
path=/tmp                         
comment=rsync test logs
#这个用户不需要服务端存在, 即rsync的认证与系统认证分离
auth users=general
#指定的验证文件, 包含用户名和密码
secrets file=/etc/rsyncd.secrets  
read only=no
list=no
hosts allow=172.16.171.132
hosts deny=0.0.0.0/32
```

服务端`/etc/rsyncd.secrets`

```
#再次说明,这里的用户是上面checksync模块指定的auth users, 不需要存在于服务端.
general:123456                    
```

修改此文件的权限

```
#修改属主
chown root:root rsyncd.secrets 　
#修改权限
chmod 600 rsyncd.secrets        
```

好了, 现在按照上面所说的rsync的daemon模式的启动方式启动吧.

然后是客户端`/etc/rsync_client.pwd`

```
#与服务端/etc/rsyncd.secrets中的密码一致就好了
123456                           
```

修改它的权限

```
#修改权限
chmod 600 rsyncd.secrets        
```

好了, 现在可以开始备份了.

### 2.3 同步命令

将本地的`/home/general/Documents`备份到服务端的`/tmp`下(因为服务端已经指明路径, 所以这里只需要指定`src`参数就好):

```
$ /usr/bin/rsync -auvzP --progress --password-file=/etc/rsync_client.pwd /home/general/Documents general@172.16.171.131::checksync
```

或者将服务端`/tmp`目录下的文件备份到本地`/tmp`目录下

```
$ /usr/bin/rsync -auvzP --progress --password-file=/etc/rsync_client.pwd  general@172.16.171.131::checksync /tmp
```

从上面两个命令可以看到, 其实这里的服务器与客户端的概念是很模糊的, `rsync daemon`都运行在远程`172.16.171.131`上, 第一条命令是本地主动推送目录到远程, 远程服务器是用来备份的; 第二条命令是本地主动向远程索取文件, 本地服务器用来备份, 也可以认为是本地服务器恢复的一个过程.

只是无法由服务端主动发起请求, 因为客户端没办法验证.