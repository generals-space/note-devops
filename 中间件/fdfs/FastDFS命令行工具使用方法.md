# FastDFS命令行工具使用方法

默认安装在`/usr/bin`目录下.

### 1. 服务命令

`fdfs_trackerd`与`fdfs_storaged`分别是trackerd与storaged的启动命令, 只接受对应的配置文件为参数, 不能使用`--help`, 也没有其他使用方法.

```
## 启动trackerd/storaged服务
$ fdfs_trackerd /etc/fdfs/tracker.conf
$ fdfs_storaged /etc/fdfs/storage.conf

## 停止trackerd/storaged服务
$ stop.sh fdfs_trackerd /etc/fdfs/tracker.conf
$ stop.sh fdfs_storaged /etc/fdfs/storage.conf

## 重启trackerd/storaged服务
$ restart.sh fdfs_trackerd /etc/fdfs/tracker.conf
$ restart.sh fdfs_storaged /etc/fdfs/storage.conf
```

## 2. 上传/下载/删除命令

**上传**

```
$ fdfs_upload_file  -h
Usage: fdfs_upload_file <config_file> <local_filename> [storage_ip:port] [store_path_index]

$ fdfs_upload_file /etc/fdfs/client.conf ./Moon.jpg 
group1/M00/00/00/rCBkhFgUZlSAeKaUAB3Idt1ih0g600.jpg
```

**下载**

```
$ fdfs_download_file -h
Usage: fdfs_download_file <config_file> <file_id> [local_filename] [<download_offset> <download_bytes>]

## 下载刚才上传的文件.
$ fdfs_download_file /etc/fdfs/client.conf group1/M00/00/00/rCBkhFgUZlSAeKaUAB3Idt1ih0g600.jpg
$ ls
rCBkhFgUZlSAeKaUAB3Idt1ih0g600.jpg
```

其中`local_filename`选项可以指定下载之后的文件名称.

**删除**

```
$ fdfs_delete_file -h
Usage: fdfs_delete_file <config_file> <file_id>

## 删除刚才上传的文件
$ fdfs_download_file /etc/fdfs/client.conf group1/M00/00/00/rCBkhFgUZlSAeKaUAB3Idt1ih0g600.jpg
## 然后storage存储目录中就没有这个文件了.
```

### 测试命令

`fdfs_test`这个命令比较全能, 可以执行上传, 下载, 删除, 查看元信息, 查看服务器状态等

```
$ fdfs_test 
This is FastDFS client test program v5.08

Copyright (C) 2008, Happy Fish / YuQing

FastDFS may be copied only under the terms of the GNU General
Public License V3, which may be found in the FastDFS source kit.
Please visit the FastDFS Home Page http://www.csource.org/ 
for more detail.

Usage: fdfs_test <config_file> <operation>
	operation: upload, download, getmeta, setmeta, delete and query_servers
```

测试上传, 请务必不要在生产环境使用，统一使用`fdfs_upload_file`命令上传.

```
$ fdfs_test /etc/fdfs/client.conf upload ./Wave.jpg
This is FastDFS client test program v5.08

Copyright (C) 2008, Happy Fish / YuQing

FastDFS may be copied only under the terms of the GNU General
Public License V3, which may be found in the FastDFS source kit.
Please visit the FastDFS Home Page http://www.csource.org/ 
for more detail.

[2016-10-29 02:40:43] DEBUG - base_path=/opt/fastdfs/client, connect_timeout=30, network_timeout=60, tracker_server_count=1, anti_steal_token=0, anti_steal_secret_key length=0, use_connection_pool=0, g_connection_pool_max_idle_time=3600s, use_storage_id=0, storage server id count: 0

tracker_query_storage_store_list_without_group: 
	server 1. group_name=, ip_addr=172.32.100.132, port=23000

group_name=group1, ip_addr=172.32.100.132, port=23000
storage_upload_by_filename
group_name=group1, remote_filename=M00/00/00/rCBkhFgUbpuAEZfxAI662SrTJ6w612.jpg
source ip address: 172.32.100.132
file timestamp=2016-10-29 02:40:43
file size=9353945
file crc32=718481324
example file url: http://172.32.100.132/group1/M00/00/00/rCBkhFgUbpuAEZfxAI662SrTJ6w612.jpg
storage_upload_slave_by_filename
group_name=group1, remote_filename=M00/00/00/rCBkhFgUbpuAEZfxAI662SrTJ6w612_big.jpg
source ip address: 172.32.100.132
file timestamp=2016-10-29 02:40:44
file size=9353945
file crc32=718481324
example file url: http://172.32.100.132/group1/M00/00/00/rCBkhFgUbpuAEZfxAI662SrTJ6w612_big.jpg
```

1. DEBUG信息返回了storage服务器的系统信息

2. Group_name:返回了storage服务器的id信息

3. remote_filename:返回了storage的存储路径。

4. source_ip address:返回了tracker server的ip地址。

5. file timestamp:返回时间戳

6. file size：上传文件的大小

7. file url：上传文件的访问地址


使用这个命令上传, 会在存储路径中生成4个文件, 总之与使用`fdfs_upload_file`命令上传产生的效果不同.

```
$ pwd
/opt/fastdfs/storage/data/00/00
$ ls
rCBkhFgUbpuAEZfxAI662SrTJ6w612_big.jpg    rCBkhFgUbpuAEZfxAI662SrTJ6w612.jpg
rCBkhFgUbpuAEZfxAI662SrTJ6w612_big.jpg-m  rCBkhFgUbpuAEZfxAI662SrTJ6w612.jpg-m
```

测试下载/删除

fdfs_test集成的下载/删除方法与`fdfs_download_file`与`fdfs_delete_file`使用方式不同. 需要指定组名`group_name`的值, `remote_filename`需要是包含路径(但不包含`M00`)的文件名.

```
Usage: fdfs_test <config_file> <download|delete> <group_name> <remote_filename>
```

```
$ fdfs_test /etc/fdfs/client.conf download  group1 00/00/rCBkhFgUbpuAEZfxAI662SrTJ6w612_big.jpg
This is FastDFS client test program v5.08

Copyright (C) 2008, Happy Fish / YuQing

FastDFS may be copied only under the terms of the GNU General
Public License V3, which may be found in the FastDFS source kit.
Please visit the FastDFS Home Page http://www.csource.org/ 
for more detail.

[2016-10-29 03:15:57] DEBUG - base_path=/opt/fastdfs/client, connect_timeout=30, network_timeout=60, tracker_server_count=1, anti_steal_token=0, anti_steal_secret_key length=0, use_connection_pool=0, g_connection_pool_max_idle_time=3600s, use_storage_id=0, storage server id count: 0

storage=172.32.100.132:23000
download file success, file size=9353945, file save to rCBkhFgUbpuAEZfxAI662SrTJ6w612_big.jpg
```

删除操作与下载操作的使用方法相同, `getmeta`,`setmeta`, `query_servers`子命令使用方法也相同. 不过`getmeta`与`setmeta`命令貌似只能对使用`fdfs_test`的`upload`子命令上传的文件有效, 对于使用`fdfs_upload_file`命令上传的文件会报错.

### 监控命令

`fdfs_monitor`命令可以监控storage服务的运行状态, 但不能查询tracker服务.

需要注意的是, 凡是曾经在同一tracker服务中注册过的storage都会出现, 只是未运行的storage会被标记为`OFFLINE`, 而正在运行的storage群会被标记为`ACTIVE`. 在一个拥有多个组的storage服务集群中, 使用`fdfs_upload_file`命令上传时, 如不指定目标storage的IP与端口, tracker会默认返回下面列出的`Group`列表中第一个状态为`ACTIVE`的组进行上传.


storage服务的运行状态有下面几种:

- FDFS_STORAGE_STATUS：INIT      :初始化，尚未得到同步已有数据的源服务器

- FDFS_STORAGE_STATUS：WAIT_SYNC :等待同步，已得到同步已有数据的源服务器

- FDFS_STORAGE_STATUS：SYNCING  :同步中

- FDFS_STORAGE_STATUS：DELETED  :已删除，该服务器从本组中摘除

- FDFS_STORAGE_STATUS：OFFLINE  :离线

- FDFS_STORAGE_STATUS：ONLINE    :在线，尚不能提供服务

- FDFS_STORAGE_STATUS：ACTIVE    :在线，可以提供服务



```
$ fdfs_monitor /etc/fdfs/storage_img.conf

server_count=1, server_index=0

tracker server is 172.32.100.132:22122

group count: 4

Group 1:
group name = group1
disk total space = 0 MB
disk free space = 0 MB
trunk free space = 0 MB
storage server count = 1
active server count = 0
storage server port = 25000
storage HTTP port = 8888
store path count = 2
subdir count per path = 256
current write server index = 0
current trunk file id = 0

	Storage 1:
		id = 172.32.100.132
		ip_addr = 172.32.100.132 (localhost.localdomain)  OFFLINE
		http domain = 
		version = 5.08
		join time = 2016-10-28 01:15:33
		up time = 
		total storage = 159062 MB
		free storage = 138852 MB
		upload priority = 10
		store_path_count = 2
		subdir_count_per_path = 256
		storage_port = 25000
		storage_http_port = 8888
		current_write_path = 0
		source storage id = 
		if_trunk_server = 0
		connection.alloc_count = 0
		connection.current_count = 0
		connection.max_count = 0
		total_upload_count = 35
		success_upload_count = 35
		total_append_count = 0
		success_append_count = 0
		total_modify_count = 0
		success_modify_count = 0
		total_truncate_count = 0
		success_truncate_count = 0
		total_set_meta_count = 2
		success_set_meta_count = 2
		total_delete_count = 1
		success_delete_count = 1
		total_download_count = 3
		success_download_count = 3
		total_get_meta_count = 1
		success_get_meta_count = 1
		total_create_link_count = 0
		success_create_link_count = 0
		total_delete_link_count = 0
		success_delete_link_count = 0
		total_upload_bytes = 210008118
		success_upload_bytes = 210008118
		total_append_bytes = 0
		success_append_bytes = 0
		total_modify_bytes = 0
		success_modify_bytes = 0
		stotal_download_bytes = 11467778
		success_download_bytes = 11467778
		total_sync_in_bytes = 0
		success_sync_in_bytes = 0
		total_sync_out_bytes = 0
		success_sync_out_bytes = 0
		total_file_open_count = 39
		success_file_open_count = 39
		total_file_read_count = 46
		success_file_read_count = 46
		total_file_write_count = 819
		success_file_write_count = 819
		last_heart_beat_time = 2016-10-29 08:02:58
		last_source_update = 2016-10-29 08:02:34
		last_sync_update = 1969-12-31 16:00:00
		last_synced_timestamp = 1969-12-31 16:00:00 
```

`fdfs_monitor`还可以查看/删除指定组, 以及指定组的指定storage服务.

```
$ fdfs_monitor 
Usage: fdfs_monitor <config_file> [-h <tracker_server>] [list|delete|set_trunk_server <group_name> [storage_id]]
```

比如, 查看组`group1`的情况

```
$ fdfs_monitor /etc/fdfs/client.conf list group1
```

如果`group1`有多个storage服务器, 还可以查看指定id的`storage`(id是列表中出现的`id`字段值).

```
$ fdfs_monitor /etc/fdfs/client.conf list group1 172.32.100.132
```