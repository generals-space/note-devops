# Linux命令-dd

<!tags!>: <!linux命令!>

参考文章

1. [Linux 下的dd命令使用详解](https://linux.cn/article-1429-1.html)


## 1. 参数解释

## 2. 应用示例

### 2.1 读写性能测试

```
## 来测试磁盘的纯写入性能. 这会从/dev/zero设备中取出字符流输出到/file文件中
## 如果不手动中止, 会写满硬盘. Ctrl+C后会显示写入速度.
## 由于/dev/zero设备的特殊性, 从其中取出字符流时不会存在读操作的性能瓶颈.
$ dd if=/dev/zero of=/file 

## 测试磁盘的纯读取性能, if指定的需要是一个存在的文件
## /file是硬盘中任一存在的文件, 这会将从这个文件中取出字符流, 输出到/dev/null设备中
## 文件系统中不会多出任何多余文件, 输出时也不会有写操作的性能瓶颈.
$ dd if=/file of=/dev/null 

## 测试磁盘的读写性能, 相当于拷贝操作, 先读后写.
$ dd if=/file1 of=/file2 
```

### 2.2 全盘数据备份恢复

```
## 将sda全盘数据备份到/root/image文件中.
$ dd if=/dev/sda of=/root/image
## 备份同时进行压缩, 此时输出操作由gzip完成, 不需要dd的of选项.
$ dd if=/dev/sda | gzip > /root/image.gz
## 将压缩的备份文件恢复到指定盘, 猜测一般是应用于类似于WinPE环境下的Ghost恢复. 此时目标盘符一般不会再是sda了, 看情况吧.
$ gzip -dc /root/image.gz | dd of=/dev/sda
```

### 2.3 备份MBR信息

由于MBR存在于硬盘最开始的512字节中, 我们需要备份`/dev/sda`的前512字节数据.

```
## 输入流依然来自/dev/sda, 不过指定只从其中拷贝count=1个块, 每个块大小为bs=512字节.
$ dd if=/dev/sda of=/root/mbr count=1 bs=512
## 恢复时就不必指定大小了, 将/root/mbr全拷贝进去就行了
$ dd if=/root/mbr of=/dev/sda
```

## 3. 特殊设备

### 3.1 /dev/mem

`/dev/mem`: 其中存储着当前内存的数据, 是内存数据的全镜像. 但由于内核的限制, `dd`命令只能访问其最开始的1M的部分. 如下.

```
$ dd if=/dev/mem of=/root/Coding/mem
dd: error reading ‘/dev/mem’: Operation not permitted
2048+0 records in
2048+0 records out
1048576 bytes (1.0 MB) copied, 0.0262912 s, 39.9 MB/s

```

### 3.2 /dev/null

/dev/null, 输出设备, 它是空设备，也称为位桶（bit bucket）。任何写入它的输出都会被抛弃。如果不想让消息以标准输出显示或写入文件，那么可以将消息重定向到位桶。

### 3.3 /dev/zero

/dev/zero，是一个输入设备，可用它来初始化文件。该设备无穷尽地提供0，可以使用任何你需要的数目——设备提供的要多的多。他可以用于向设备或文件写入二进制0。

### 3.4 /dev/urandom

`/dev/urandom`: 输入设备, 与`/dev/zero`类似. 它可以提供无限的随机数据, 在某些场合可以利用它来销毁数据.

```
$ dd if=/dev/urandom of=/dev/sda1
```