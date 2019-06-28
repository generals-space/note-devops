# RSync触发式同步-inotify工具

参考文章

[Linux下同步工具inotify+rsync使用详解](http://seanlook.com/2014/12/12/rsync_inotify_setup/)

与传统的cp, tar备份方式相比, rsync具有安全性高, 备份迅速, 支持增量备份等优点, 通过rsync可以解决对实时性要求不高的数据备份需求, 例如定期的备份文件服务器数据到远端服务器, 对本地磁盘定期做数据镜像等.

随着应用系统规模的不断扩大, 对数据的安全性和可靠性也提出的更好的要求, rsync在高端业务系统中也逐渐暴露出了很多不足, 首先, rsync同步数据时, 需要扫描所有文件后进行比对, 进行差量传输. 如果文件数量达到了百万甚至千万量级, 扫描所有文件将是非常耗时的. 而且正在发生变化的往往是其中很少的一部分, 这是非常低效的方式. 其次, rsync不能实时的去监测, 同步数据, 虽然它可以通过crontab方式进行触发同步, 但是两次触发动作一定会有时间差, 这样就导致了服务端和客户端数据可能出现不一致, 无法在应用故障时完全的恢复数据. 基于以上原因, `rsync+inotify`组合出现了!

## 1. inotify

### 1.1 inotify机制

inotify是一种强大的, 细粒度的, 异步的文件系统事件监控机制，Linux内核从2.6.13开始引入，允许监控程序打开一个独立文件描述符，并针对事件集监控一个或者多个文件，例如打开, 关闭, 移动/重命名, 删除, 创建或者改变属性.

使用`ll /proc/sys/fs/inotify`命令, 是否有以下三条信息输出, 如果没有表示不支持.

```shell
$ ll /proc/sys/fs/inotify
total 0
-rw-r--r--. 1 root root 0 Oct 21 10:37 max_queued_events
-rw-r--r--. 1 root root 0 Oct 21 10:37 max_user_instances
-rw-r--r--. 1 root root 0 Oct 21 08:50 max_user_watches
```

`/proc/sys/fs/inotify/max_queued_evnets`表示调用`inotify_init`时分配给`inotify instance`中可排队的event的数目的最大值, 超出这个值的事件被丢弃, 但会触发`IN_Q_OVERFLOW`事件.

`/proc/sys/fs/inotify/max_user_instances`表示每一个`real user ID`可创建的`inotify instatnces`的数量上限.

`/proc/sys/fs/inotify/max_user_watches`表示每个`inotify instatnces`可监控的最大目录数量. 如果监控的文件数目巨大, 需要根据情况, 适当增加此值的大小.

### 1.2 inotify-tools

`inotify-tools`是为linux下inotify文件监控工具提供的一套C的开发接口库函数, 同时还提供了一系列的命令行工具. 这些工具可以用来监控文件系统的事件.

`inotify-tools`是用C编写的, 除了要求内核支持`inotify`外, 不依赖于其他. `inotify-tools`提供两个工具命令, 一是`inotifywait`, 它是用来监控文件或目录的变化, 二是`inotifywatch`, 它被用来统计文件系统访问的次数.

如果没有此工具可用rpm或是yum安装.

### 1.3 inotifywait

使用`inotifywait`命令监控`/home/jiangming`目录文件的变化:

```
inotifywait -mrq --timefmt '%Y/%m/%d-%H:%M:%S' --format '%T %w %f' -e modify,delete,create,move,attrib /home/jiangming/
```

上面的命令表示, 持续监听`/home/jiangming`目录及其子目录的文件变化, 监听事件包括文件被修改, 删除, 创建, 移动, 属性更改, 显示到屏幕. 执行完上面的命令后, 在`/home/jiangming`下创建或修改文件都会有信息输出:

```
[root@localhost tmp]# inotifywait -mrq --timefmt '%Y/%m/%d-%H:%M:%S' --format '%T %w %f' -e modify,delete,create,move,attrib /root
2015/10/21-10:48:33 /home/jiangming/ vgauthsvclog.txt.0   #删除此文件
2015/10/21-10:48:58 /home/jiangming/ testfile             #创建新文件
2015/10/21-10:48:58 /home/jiangming/ testfile
...
```

## 2. rsync与inotify的结合

这一步的核心其实就是在**客户端**创建一个脚本`rsync.sh`, 适用`inotifywait`监控本地目录的变化, 触发`rsync`将变化的文件传输到远程备份服务器上. 为了更接近实战, 我们要求一部分子目录不同步, 如`/jiangming/tmp/`和临时文件.

### 2.1 创建排除在外不同步的文件列表

排除不需要同步的文件或目录有两种做法, 第一种是inotify监控整个目录, 在rsync中加入排除选项, 简单；第二种是inotify排除部分不监控的目录, 同时rsync中也要加入排除选项, 可以减少不必要CPU消耗. 我们选择第二种.

#### 2.1.1 inotifywait排除

这个操作在客户端进行(想想为什么?), 假设`/home/jiangming/tmp`的所有文件以及`/home/jiangming/`目录下的临时文件不用同步, 所以不需要监控, `/home/jiangming/`下的其他文件和目录都同步.(其实对于打开的临时文件, 可以不监听`modify`事件而改成监听`close_write`)

`inotifywait`排除监控目录有`--exclude <pattern>`和`--fromfile <file>`两种格式, 并且可以同时使用, 但主要前者可以用正则, 而后者只能是具体的目录或文件.

使用`fromfile`格式只能用绝对路径, 而且其中的内容不能使用诸如*正则表达式去匹配, @表示排除.

```
# vim /etc/inotify_watched.lst：
/home/jiangming/                           #要监控的目录
@/home/jiangming/tmp/                 #要排除的目录
```

如果要排除的格式比较复杂, 必须使用正则, 那只能在`inotifywait`中加入选项, 如`--exclude '(\.log|\.swp)$'`, 表示排除所有的以`.log`或`.swp`结尾的文件.

#### 2.1.2 rsync排除

使用`inotifywait`排除监控目录的情况下, 必须同时使用rsync排除对应的目录, 否则只要有触发同步操作, 必然会导致不该同步的目录也会同步. 与`inotifywait`类似, `rsync`的同步也有`--exclude`和`--exclude-from`两种写法(其实也有include的相应的写法的).

个人还是习惯将要排除同步的目录写在单独的文件列表里, 便于管理. 使用`--exclude-from=FILE`时, 排除文件列表用绝对路径, 但FILE里面的内容请用相对路径(相对于rsync命令中的src哦), 如:

```
vim /etc/rsync_exclude.lst
tmp/
*.log
*.swp
```

```
rsync -azP --delete --exclude-from=/etc/rsync.exclude.lst /home/jiangming dst
```

这样就能在同步时排除/home/jiangming/tmp/目录下的内容了.

### 2.2 客户端同步到远程的脚本rsync.sh

```shell
#!/bin/bash
#rsync+inotify触发式同步脚本
#由inotify检测到目标目录的文件变化, 然后调用rsync扫描, 同步
#2014-12-11 Sean
#一些变量

#注意最后的/存在与否的意义不同呢
source_path=/home/jiangming/      
log_file=/var/log/rsync_client.log

#对应rsync服务端的配置
rsync_server=172.16.171.131
rsync_user=jiangming
rsync_pwd=/etc/rsync_client.pwd
rsync_module=checksync
INOTIFY_EXCLUDE='(\.log|\.swp)$'
RSYNC_EXCLUDE='/etc/rsync_exclude.lst'

#rsync客户端密码文件是否存在
if [ ! -e ${rsync_pwd} ];then
    echo -e "rsync客户端密码文件 ${rsync_pwd} 不存在!"
    exit 0
fi

#inotify_function(其实这是一行脚本, 只是太长了些):
#inotify检测到文件变化传给rsync, 然后rsync扫描目标目录查询变化, 发起同步
inotify_fun(){
    /usr/bin/inotifywait -mrq		\
    --timefmt '%Y/%m/%d-%H:%M:%S' --format '%T %w %f' \ #这两个貌似只能放在同一行哦
    --exclude ${INOTIFY_EXCLUDE}  	\
    -e modify,delete,create,move,attrib	\
    ${source_path} \
    | while read file
	do
        #下面这一行好像还不能用\分割
        ## --bwlimit=200  用于限制传输速率最大200kb, 因为在实际应用中发现如果不做速率限制, 会导致巨大的CPU消耗
	    /usr/bin/rsync -auvzP   --delete  --exclude-from=${RSYNC_EXCLUDE}   --progress    --bwlimit=200   --password-file=${rsync_pwd}  ${source_path}    ${rsync_user}@${rsync_server}::${rsync_module} 
	done
}

#inotify log
inotify_fun >> ${log_file} 2>&1 &    #后台执行
```

在客户端运行脚本`./rsync.sh`即可实时同步目录.

