# FastDFS应用场景

## 1. 单台storage服务器, 多个存储路径

如果一台`storage`服务器上挂载有多块大容量硬盘, 分别对应不同的路径, 如`/data01`, `/data02`与`/data03`. 要将这3个路径对应的分区(或者说对应的硬盘)同时利用起来, 需要修改`storage.conf`中的`store_path`字段.

```
$ vim /etc/fdfs/storage.conf
...
## store_path_count是说明, 当前storage服务器上有3个存储位置, 分别由store_path字段指定
store_path_count=3
## store_path字段指定上传文件的实际存储路径, 其索引值从0开始
store_path0=/data01
store_path1=/data02
store_path2=/data03
```

重启storage服务.

```
$ restart.sh fdfs_storaged /etc/fdfs/storage.conf
```

测试上传, 28张图片. 由于`fdfs_upload_file`命令中只配置了tracker服务器, 所以对storage的修改对`client.conf`中的配置并无影响, 按照原来的方式上传即可.

```
$ for i in $(ls *.jpg); do fdfs_upload_file /etc/fdfs/client.conf $i; done
group1/M00/00/00/rCBkhFgUg8KAS_7tAJBBIxn9OUo426.jpg
group1/M01/00/00/rCBkhFgUg8OAVGN9APQRzEXgdxc876.jpg
group1/M02/00/00/rCBkhFgUg8OAGxSQAHahfrwkP34328.jpg
group1/M00/00/00/rCBkhFgUg8SAYXRfAE4lMQkXtMc829.jpg
group1/M01/00/00/rCBkhFgUg8SACXn2ABpIaYvZfD8159.jpg
group1/M02/00/00/rCBkhFgUg8SACRCdADyzazsp4DE112.jpg
group1/M00/00/00/rCBkhFgUg8SAKiN4AEP1Ky4oemg526.jpg
group1/M01/00/00/rCBkhFgUg8WAG3a-ALpMUo7Kpk8024.jpg
group1/M02/00/00/rCBkhFgUg8WAQbIZAMcdEb_0Gnw733.jpg
group1/M00/00/00/rCBkhFgUg8aAXyoCAI_ja3oZwQ8653.jpg
group1/M01/00/00/rCBkhFgUg8aACfjdAH2JXwf9FO0631.jpg
group1/M02/00/00/rCBkhFgUg8eANMJpAEKHUpjlXbE868.jpg
group1/M00/00/00/rCBkhFgUg8eAZvIGAFhIOPsNwN8699.jpg
group1/M01/00/00/rCBkhFgUg8eAUK9AAHutokfAVJo268.jpg
group1/M02/00/00/rCBkhFgUg8iAdkHjADrnsfpg_rA308.jpg
group1/M00/00/00/rCBkhFgUg8iAfZoaAI1XQCD_Yl4723.jpg
group1/M01/00/00/rCBkhFgUg8iAYxt4AB04xtkdaeg390.jpg
group1/M02/00/00/rCBkhFgUg8mAOFLKAEmQeIf0mbI918.jpg
group1/M00/00/00/rCBkhFgUg8mAQqAiAFQRgcoVfw8343.jpg
group1/M01/00/00/rCBkhFgUg8mAV_-0AB3Idt1ih0g546.jpg
group1/M02/00/00/rCBkhFgUg8mAIAsjAER6PCYZUxk485.jpg
group1/M00/00/00/rCBkhFgUg8qAJXuzAGilHvnZEdU216.jpg
group1/M01/00/00/rCBkhFgUg8qAfOBZACsv22b7QvQ121.jpg
group1/M02/00/00/rCBkhFgUg8uAfXuDAEW-lQfJJpM648.jpg
group1/M00/00/00/rCBkhFgUg8uADfWtAEf4FGgA2Zs624.jpg
group1/M01/00/00/rCBkhFgUg8uAV944ACByNvHRQxM614.jpg
group1/M02/00/00/rCBkhFgUg8uANMFqADwOI0kPjMI813.jpg
group1/M00/00/00/rCBkhFgUg8yAf51lAI662SrTJ6w459.jpg
```

可以看到, `Mxx`代表存储块的挂载路径id.

不过, 这样的话, nginx也要重新配置. 比如

```conf
location /group1/M00{
    root /data01;
    ngx_fastdfs_module;
}
location /group1/M01{
    root /data02;
    ngx_fastdfs_module;
}
location /group1/M02{
    root /data03;
    ngx_fastdfs_module;
}
```

**记得要在`/dataXX`目录下, 建立与data同级的`M00`, `M01`..等链接**.

## 2. nginx访问路径不带group名称

group名称就是出现在url中`http://服务器IP/group1/M00/00/00/rBADllgSG-CAFgdCAAJ4s5Ymywc291.zip`的`group1`. 如果不想在url中出现这个`group1`, 需要修改两处地方.

首先是nginx的`location`字段, 去掉`group1`前缀.

```
## location /group1/M00{
location /M00{
    root /opt/fastdfs/storage;
    ngx_fastdfs_module;
}
```

然后修改`/etc/fdfs/mod_fastdfs.conf`文件.

```conf
## 将这个字段的值设置为false
url_have_group_name = false
```

重启nginx.

之后访问上传的文件时, 就不用再加`group1`这一段了. 如`http://服务器IP/M00/00/00/rBADllgSG-CAFgdCAAJ4s5Ymywc291.zip`.

## 3. 多个group

当想用同一组fdfs集群同时做多个网站的文件存储时, 需要定义不同的组, 指定不同的存储路径. 不同组之间的数据不相互干扰. 

不同组的storage服务, 如果在同一台服务器上, 需要监听不同的端口, 但是可以共用同一个tracker服务.

复制一份`/etc/fdfs/storage.conf`为`storage_img.conf`, 作为图片存储服务. 将其配置修改为如下.

```
$vim /etc/fdfs/storage_img.conf
...
##新组名
group_name=img
## 如果在同一台服务器上, 则每个组监听的端口必须不同
port=24000
## 存储路径也要不同...相同也没关系, 不过就没什么意义了, 还不如直接用同一个...
base_path=/opt/fastdfs/storage_img
store_path0=/opt/fastdfs/storage_img
## 不同组的storage服务器可以用同一个tracker_server, tracker一般不会是瓶颈.
tracker_server=172.32.100.132:22122
```

然后启动新的storage服务, tracker会检测到新的storage服务加入, 在其日志中会出现如下记录

```
$ fdfs_storaged /etc/fdfs/storage_img.conf
...

storage server img::172.32.100.132 join in, remain changelog bytes: 0
storage server img::172.32.100.132 now active
```

使用`fdfs_upload_file`命令测试上传, 由于存在多个storage服务, 所以现在上传需要指定上传到哪一个组.

------

然后, 想要通过nginx访问指定组的文件, 需要配置`mod_fastdfs.conf`文件.

```conf
## 首先是group_count字段, 表示支持访问的组的个数. 默认是0, 只支持单个组
group_count = 2
## 多个组的时候, 这个必须要设为true
url_have_group_name = true
## 然后分别对各个组进行配置, 这一部分在mod_fastdfs的末尾. 在这之前, 记得先删除/注释原来的group_name, storage_server_port等字段的定义, 否则会重复
[group1]
group_name=group1
storage_server_port=23000
store_path_count=1
store_path0=/opt/fastdfs/storage

[group2]
group_name=img
storage_server_port=24000
store_path_count=1
store_path0=/opt/fastdfs/storage_img
```

还有`nginx.conf`文件

```
location /group1/M00{
    root /opt/fastdfs/storage;
    ngx_fastdfs_module;
}
location /img/M00{
    root /opt/fastdfs/storage_img;
    ngx_fastdfs_module;
}
```

**别忘了在新组`img`的存储目录下建立`M00`软链接**.

访问格式: `服务器IP/img/M00/00/00/rCBkhFgUt22AXX-eADrnsfpg_rA739.jpg`.

## 4. fdfs集群配置

首先客户端 client 发起对 FastDFS 的文件传输动作，是通过连接到某一台 Tracker Server 的指定端口来实现的，Tracker Server 根据目前已掌握的信息，来决定选择哪一台 Storage Server ，然后将这个Storage Server 的地址等信息返回给 client，然后 client 再通过这些信息连接到这台 Storage Server，将要上传的文件传送到给 Storage Server上。
