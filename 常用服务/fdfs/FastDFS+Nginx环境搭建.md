# FastDFS环境搭建

## 写在前面

FastDFS是一个开源的, 高性能的的分布式文件系统, 主要的功能包括: 文件存储, 同步和访问, 设计基于高可用和负载均衡. FastDFS非常适用于基于文件服务的站点, 例如图片分享和视频分享网站.

FastDFS有两个角色: 跟踪服务(tracker)和存储服务(storage).

- 跟踪服务: 控制调度文件以负载均衡的方式访问.

- 存储服务: 文件存储, 文件同步, 提供文件访问接口, 同时以key value的方式管理文件的元数据.

跟踪和存储服务都可以由1台或者多台服务器组成, 同时可以动态的添加, 删除跟踪和存储服务而不会对在线的服务产生影响, 在集群中, tracker服务是对等的.

fastdfs原来是`sourceforge`上的项目, 不过已经停止更新(当前最新版为1.27), 现在迁移到了github(目前最新版为5.05), [项目地址](https://github.com/happyfish100/fastdfs).

fastdfs源码编译依赖`libevent`库, 这个可以使用yum安装; 另外它还依赖`libfastcommon`, yum源中应该没有需要源码安装, 也是在github上可以找到其源码, [项目地址](https://github.com/happyfish100/libfastcommon).

nginx需要对应的fastdfs扩展, 名为`fastdfs-nginx-module`. 同样, 其在`sourceforge`上的版本已经过于陈旧, 不推荐使用. github上的[项目地址](https://github.com/happyfish100/fastdfs-nginx-module).

## 1. 环境要求

- 系统版本: CentOS6

- fastdfs: 5.08

- nginx: 1.10.1



## 2. 安装步骤

> 注意: 这一部分是`tracker`与`storage`服务器都需要安装的.

说明一点, 这个版本不需要安装`libevent`与`libevent-devel`库(之前在`sourceforge`上的`1.27`版是需要的). 

首先是`libfastcommon`, [github链接](https://github.com/happyfish100/libfastcommon), 在此依赖包的根目录下直接执行如下命令即可, 可以参见`INSTALL`文件.

> 注意: 到2016-10-27为止, libfastcommon都要用master分支的, tag中有一个`1.0.7`版, 但无法正常使用, 安装fastdfs时会编译出错.

```shell
cd libfastcommon
./make.sh && ./make.sh install
```

接下来是`fastdfs`本身.

上面安装`libfastcommon`会在`/usr/lib64`目录生成`libfastcommon.so`与`libfdfsclient.so`两个文件, 网上有说需要将其软链接到`/usr/lib`与`/usr/local/lib`, 但经过实验这一步是不需要的. 另外, 网上有之前版本需要解开`HTTPD`与`LINUX SERVICE`的注释, 这一版本的`make.sh`不需要作任何修改, 同上面的`libfastcommon`安装方式一样, 简单粗暴.

```shell
cd FastDFS目录
./make.sh && ./make.sh install
```

安装完成后fdfs会交由`service`管理, 在`/etc/init.d`目录下会生成`fdfs_trackerd`与`fdfs_storaged`两个启动脚本, ~~所以可以以服务形式启动与关闭~~. 咳, 在CentOS7下这两个脚本不太好使, 所以这篇文章里不使用服务方式启停fastdfs.

fdfs系列的命令也已经添加到`/usr/local/bin`目录下, 可以直接执行. 

且其配置文件会放在`/etc/fdfs`目录下, 有`client.conf.sample`, `storage.conf.sample`, `tracker.conf.sample`三个配置. 接下来我们修改这些配置.

## 3. 配置方法

`storage`与`client`配置文件中都有`tracker_server`的配置, 所以先配置`tracker`

### 3.1 tracker

```
$ cd /etc/fdfs
## 这个版本的配置文件默认都以.sample结尾
$ ls
client.conf.sample  storage.conf.sample  tracker.conf.sample
$ mv ./tracker.conf.sample ./tracker.conf
$ vim ./tracker.conf
```

tracker.conf的文件内容.

```conf
## 这个路径可以自定义, 但必须是已经存在的, fdfs不能自动创建
## 这个路径存储数据及日志文件
base_path=/opt/fastdfs/tracker
```

其他的如`port`与`http.server_port`最好先保持默认, 等熟悉之后再根据需要修改

启动tracker服务：

```
$ fdfs_trackerd /etc/fdfs/tracker.conf 
```

### 3.2 storage

步骤基本与`tracker`一致.

```
$ cd /etc/fdfs
## 这个版本的配置文件默认都以.sample结尾
$ ls
client.conf.sample  storage.conf.sample  tracker.conf
$ mv ./storage.conf.sample ./storage.conf
$ vim ./storage.conf
```

storage.conf的文件内容.

```conf
## 这个路径是存储日志文件的路径, 路径可以自定义, 但必须是已经存在的, fdfs不能自动创建
base_path=/opt/fastdfs/storage
## 上传文件的存储路径, 这个路径也必须存在
store_path0=/opt/fastdfs/storage
## tracker_server的地址, IP:port
tracker_server=172.16.3.150:22122
```

`$base_path`目录下会生成`data`目录, 存放storage服务的pid文件和状态信息文件, 还有`log`目录, 存放storage服务的日志文件. `store_path0`目录下会生成`data`目录, 下面是存放的上传的数据文件.

其他的如`port`与`http.server_port`最好先保持默认, 等熟悉之后再根据需要修改

启动storaged服务：

```
$ fdfs_storaged storage.conf 
```

### 3.3 配置client并测试上传

这里的client是直接使用fdfs提供的接口执行文件上传/下载操作的工具.

```
$ cd /etc/fdfs
## 这个版本的配置文件默认都以.sample结尾
$ ls
client.conf.sample  storage.conf  tracker.conf
$ mv ./client.conf.sample ./client.conf
$ vim ./client.conf
```

client.conf的文件内容.

```conf
## 这个路径可以自定义, 但必须是已经存在的, fdfs不能自动创建
## 这个路径写client的日志文件存放路径, 必须存在...不过好像不会生成什么东西, 一直是空的.
base_path=/opt/fastdfs/client
## tracker_server的地址, IP:port
tracker_server=172.16.3.150:22122
```

测试上传

```shell
## 需要指定client配置文件的路径
fdfs_upload_file /etc/fdfs/client.conf ./libfastcommon-master.zip
group1/M00/00/00/rBADllgSG-CAFgdCAAJ4s5Ymywc291.zip
```

将会上传`libfastcommon-master.zip`, 上传结果中的`group1/M00`这个前缀是fdfs识别的, `group1`是在`storage.conf`文件中配置的`group_name`值. 我们到fdfs的storage配置中的`$base_path`的`data`中查看文件的实际存储路径, 可以看到目标文件存在, 且该文件的上传时间与大小完全符合我们的原文件.

```
ls /opt/fastdfs/storage/data/00/00
rBADllgSG-CAFgdCAAJ4s5Ymywc291.zip
```

## 4. 配置fdfs的nginx接口

nginx接口用于访问上传的文件, 需要安装对应的fastdfs提供的第三方模块.

### 4.1 安装前准备

下载`fastdfs-nginx-module`模块, [github地址](https://github.com/happyfish100/fastdfs-nginx-module).

然后安装nginx的依赖, 配置编译项, 在执行`./configure`命令时, 指定`fastdfs-nginx-module`第三方模块, 格式如下, 然后执行`make && make install`

```
--add-module=fastdfs-nginx-module的路径/src/
```

### 4.2 nginx配置

修改nginx配置如下

```conf
location /group1/M00{
    root /opt/fastdfs/storage;
    ngx_fastdfs_module;
}
```

在`stroage`的`$store_path`目录下创建其下`data`的软链接, 链接目标为`data`同级的`M00`

```
$ ln -s /opt/fastdfs/storage/data /opt/fastdfs/storage/M00
```

------

拷贝`fastdfs-nginx-module`的src目录下的`mod_fastdfs.conf`文件到`/etc/fdfs/`下, nginx的fastdfs模块需要加载这个配置文件, 修改方法如下, 和tracker/storage的配置类似.

```conf
## group_name就是使用client工具上传时的`group1`
url_have_group_name=true
## tracker_server的地址, IP:端口
tracker_server=172.16.3.150:22122
## 指定该模块的日志路径, 不过好像没有日志生成...
base_path=/tmp
## store_path与storage的store_path保持一致
store_path0=/opt/fastdfs/storage
```

------

将fastdfs源码目录conf子目录下的的2个文件复制到`/etc/fdfs`目录下：

```
cp fastdfs源码目录/conf/http.conf /etc/fdfs
cp fastdfs源码目录/conf/mime.types /etc/fdfs
```

### 4.3 测试访问

访问上面我们使用`fdfs_upload_file`命令上传的文件.

```
wget 服务器IP/group1/M00/00/00/rBADllgSG-CAFgdCAAJ4s5Ymywc291.zip
```

## FAQ

### 1.

```
cc -Wall -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -g -O -DDEBUG_FLAG -c -o tracker_service.o tracker_service.c  -I../common -I/usr/include/fastcommon
In file included from /usr/include/fastcommon/fast_task_queue.h:19:0,
                 from tracker_nio.h:17,
                 from tracker_service.c:34:
/usr/include/fastcommon/ioevent.h:82:2: error: #error port me
 #error port me
  ^
/usr/include/fastcommon/ioevent.h:95:2: error: #error port me
 #error port me
  ^
/usr/include/fastcommon/ioevent.h:108:2: error: #error port me
 #error port me
  ^
tracker_service.c: In function ‘tracker_deal_reselect_leader’:
tracker_service.c:1743:21: warning: variable ‘pClientInfo’ set but not used [-Wunused-but-set-variable]
  TrackerClientInfo *pClientInfo;
                     ^
make: *** [tracker_service.o] Error 1
```

问题描述:

在执行fastdfs下的make.sh时, 编译出错, tracker与stroage都没有编译成功

解决办法:

这种情况有可能是在github上下载的`libfastcommon`源码包不是master, tag中的`1.0.7`版会使fastdfs编译出错.