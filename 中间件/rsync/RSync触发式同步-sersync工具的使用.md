RSync触发式同步-sersync工具的使用

参考文章

[sersync官方文档](https://code.google.com/archive/p/sersync/)

[rsync+inotify-tools](https://github.com/wsgzao/sersync)

[Sersync试用](https://my.oschina.net/guol/blog/120199)

[Linux rsync目录同步功能实现](http://blog.csdn.net/gnufre/article/details/6981091)

## 1. 认知问题

1. 双方的rsync版本不必完全一致, 较小的差距可以忽略, 如`3.0.6`与`3.0.9`之间同步没有出现问题.

2. 服务形式的`rsync`与客户端的认证与系统用户认证相互独立.

3. 服务端`rsync`最好以root用户启动, 这样`rsync`客户端在同步过程中会将本地的用户权限一并传输到服务端. 如果客户端文件`a.txt`属主为用户`A`, 其`uid`为`500`, 而服务端不存在此用户, 则同步到服务端时该文件的属主将会变成`500`; 而如果服务端存在一个用户B的`uid`正好是`500`, 那么此文件`a.txt`的属主就会成为`B`. 这一点需要注意.

## 2. sersync使用方法

`sersync`最新的版本是`2.5.4`, 发布于2011年, 之后就再也没有更新过. 可以将它看作是`rsync + inotify`的结合, 运行在客户端, 通过自定义的配置文件协调两者的运行, 不再需要编写复杂的inotify脚本及rsync的同步命令, 尤其是需要指定过滤条件传输速率等参数的情况.

`sersync`只有一个可执行文件和一个配置文件, 不过系统中还是需要安装有`rsync`与`inotify-tools`.

### 2.1 服务端配置

这里的服务端角色一般是指以服务形式运行`rsync`, 接收来自客户端的同步请求而作的备份服务器. 没有的话使用yum安装.

首先是rsync主配置文件`/etc/rsyncd.conf`, 没有的话可以需要手动创建.

```
uid = root
gid = root
use chroot = no 
max connections = 3600
port = 10873
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log

## 这一语句块可以存在多个, 名称任意, 客户端可以通过不同的认证用户, 指定不同的名字将数据同步到不到目录下. 不过客户端的密码文件貌似需要分开写...
[ew4_ftp]
## 同步过来的数据存放的位置, 这个目录需要预先创建
path = /tmp/ew4
ignore errors = yes
read only = no
## 此用户不必真实存在
auth users = locals3
secrets file = /etc/rsync.pass
```

```
## 第一个locals3是认证用户, 第二个是认证密码, 都可随意指定
$ echo 'locals3:locals3' > /etc/rsync.pass
$ chmod 600 /etc/rsync.pass
$ /usr/bin/rsync --daemon
```

### 2.2 客户端sersync配置

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<head version="2.5">
    <host hostip="localhost" port="8008"></host>
    <debug start="false"/>
    <fileSystem xfs="false"/>
    <filter start="false">
        <exclude expression="(.*)\.svn"></exclude>
        <exclude expression="(.*)\.swp"></exclude>
    </filter>
    <inotify>
        <!--rsync的delete选项, 会删除服务端目录中的无关文件. 即, 如果服务端有文件A, 而客户端没有, 那么在同步时会将服务端的文件A删除-->
        <delete start="true"/>
        <createFolder start="true"/>
        <createFile start="false"/>
        <closeWrite start="true"/>
        <moveFrom start="true"/>
        <moveTo start="true"/>
        <attrib start="false"/>
        <modify start="false"/>
    </inotify>

    <sersync>
        <!--本地监听目录-->
        <localpath watch="/opt/vsftp/test">
            <!--服务端地址及模块名称-->
            <remote ip="192.168.166.220" name="ew4_ftp"/>
        </localpath>
        <rsync>
            <commonParams params="-artuz"/>
            <!--指定认证用户名称及密码文件, 注意start属性首先要设置为true-->
            <auth start="true" users="locals3" passwordfile="/usr/local/sersync2/rsync_client.pwd"/>
            <!--如果服务端rsync为自定义端口, 则这里需要做相应修改. 注意start属性首先要设置为true-->
            <userDefinedPort start="true" port="10873"/><!-- port=874 -->
            <timeout start="false" time="100"/><!-- timeout=100 -->
            <ssh start="false"/>
        </rsync>
        <!--未同步成功的文件被记录在这个脚本中, 每隔timeToExecute分钟执行一遍此脚本, 如成功, 就将其从该脚本中删除-->
        <failLog path="/tmp/rsync_fail_log.sh" timeToExecute="60"/><!--default every 60mins execute once-->
        <crontab start="false" schedule="600"><!--600mins-->
            <crontabfilter start="false">
                <exclude expression="*.php"></exclude>
                <exclude expression="info/*"></exclude>
            </crontabfilter>
        </crontab>
        <plugin start="false" name="command"/>
    </sersync>
    <!--之后的暂时不用管-->
    <plugin name="command">
        <param prefix="/bin/sh" suffix="" ignoreError="true"/>  <!--prefix /opt/tongbu/mmm.sh suffix-->
        <filter start="false">
            <include expression="(.*)\.php"/>
            <include expression="(.*)\.sh"/>
        </filter>
    </plugin>

    <plugin name="socket">
        <localpath watch="/opt/tongbu">
            <deshost ip="192.168.138.20" port="8009"/>
        </localpath>
    </plugin>
    <plugin name="refreshCDN">
        <localpath watch="/data0/htdocs/cms.xoyo.com/site/">
            <cdninfo domainname="ccms.chinacache.com" port="80" username="xxxx" passwd="xxxx"/>
            <sendurl base="http://pic.xoyo.com/cms"/>
            <regexurl regex="false" match="cms.xoyo.com/site([/a-zA-Z0-9]*).xoyo.com/images"/>
        </localpath>
    </plugin>
</head>
```

然后在`/usr/local/sersync2/rsync_client.pwd`文件中写入认证密码, 这个路径在上面xml配置文件的`passwordfile`字段中指定. 注意pwd文件的权限必须是600.

```
$ echo 'locals3' > /usr/local/sersync2/rsync_client.pwd
$ chmod 600 /usr/local/sersync2/rsync_client.pwd
```


```
## 在监控前，将监控目录与远程主机用rsync命令推送一遍
$ ./sersync2 -r
## 启用守护进程模式
$ ./sersync2 -d
```

## 3. 关于同步方式-inotify块理解

```xml
    <inotify>
        <!--rsync的delete选项, 会删除服务端目录中的无关文件. 即, 如果服务端有文件A, 而客户端没有, 那么在同步时会将服务端的文件A删除-->
        <delete start="true"/>
        <createFolder start="true"/>
        <createFile start="false"/>
        <closeWrite start="true"/>
        <moveFrom start="true"/>
        <moveTo start="true"/>
        <attrib start="false"/>
        <modify start="false"/>
    </inotify>
```

假设客户端初始目录结构如下

```
.
`-- sky_crawl
    |-- ppl_data
    |   `-- ppl_data_file
    `-- umeng_crawl
        `-- umeng_crawl_file
```

在`sersync2 -r`情况下

delete字段start属性为`true`且createFolder的start也为`true`时, sersync2会将服务端有而客户端没有的数据都删除掉, 即用客户端的**目录结构**覆盖掉服务端目录. 

假如客户端的目录结构如下

```
A目录
    B文件
D文件
```

服务器的目录结构为

```
A目录
    B文件
    C文件
D文件
```

其中两者的B文件不相同.

使用默认属性选项执行`-r`时, 服务器端的C文件会被删除, B文件将被客户端的B文件替换, 但是D文件将保持不变. 我觉得可以理解为, 由于C文件的不同触发了A目录下所有文件的替换操作, 而D文件存在于与客户端相同的目录结构中, 所以没有更改...

------

当delete的start设置为false, 而createFolder的start为true时, 同步过程中不会删除服务端存在的数据, 但是如果存在同名目录, 则会在服务端同名目录下再次创建一个同名目录, 然后把原来服务端存在的数据移进去.

当delete的start为false, createFolder的也为false时, 同步过程中不会删除服务端已经存在的数据, 同名目录下的内容将会合并. 但是在`sersync2 -d`情况下, createFolder的start属性为false时, 客户端新建目录的操作不会被同步到服务端. 所以, 在需要将客户端内容追加到服务端时, `sersync2 -r`操作需要将`createFolder`设置为false(避免同名目录冲突), 同步完成之后, `sersync2 -d`操作需要将`createFolder`设置为true(同步正常的目录创建的操作).

<???>