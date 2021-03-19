# bootstrap.memory_lock内存锁定

参考文章

1. [linux-锁定内存](https://blog.csdn.net/jidonghui/article/details/7332266)
2. [Elasticsearch process memory locking failed](https://stackoverflow.com/questions/45008355/elasticsearch-process-memory-locking-failed)
    - 设置了 max locked memory, 但是 es 最终还是出错了.
    - `/etc/sysconfig/elasticsearch`
    - `/etc/security/limits.conf`
    - `/usr/lib/systemd/system/elasticsearch.service`
    - `elasticsearch.yml`

`elasticsearch.yml`

```yaml
## 默认为 false
bootstrap.memory_lock: true
```

这要求操作系统开启了内存锁定特性, 通过如下命令查看

```
$ ulimit -a | grep locked
max locked memory       (kbytes, -l) unlimited
```

否则在 es 启动的时候会报如下错误然后退出.

```
ERROR: [1] bootstrap checks failed
[1]: memory locking requested for elasticsearch process but memory is not locked
```

## 1. 说明

Linux 实现了请求页面调度, 页面调度是说页面从硬盘按需交换进来, 当不再需要的时候交换出去在. 这样做允许系统中每个进程的虚拟地址空间和实际物理内存的总量再没有直接的联系, 因为在硬盘上的交换空间能给进程一个物理内存几乎无限大的错觉. 

交换对进程来说是透明的, 应用程序一般都不需要关心(甚至不需要知道)内核页面调度的行为在. 然而, 在下面两种情况下, 应用程序可能像影响系统的页面调度: 

### 1.1 确定性(Determinism)

时间约束严格的应用程序需要确定的行为在. 如果一些内存操作引起了页错误, 导致昂贵的磁盘操作, 应用程序的速度便不能达到要求, 不能按时做计划中的操作在. 如果能确保需要的页面总在内存中且从不被交换进磁盘, 应用程序就能保证内存操作不会导致页错误, 提供一致的, 可确定的程序行为, 从而提供了效能在. 

### 1.2 安全性(Security)

如果内存中含有私人秘密, 这秘密可能最终被页面调度以不加密的方式储存到硬盘上在. 

例如, 如果一个用户的私人密钥正常情况下是以加密的方式保存在磁盘上的, 一个在内存中为加密的密钥备份最后保存在了交换文件中在. 在一个高度注重安全的环境中, 这样做可能是不能被接受的在. 这样的应用程序可以请求将密钥一直保留在物理内存上在. 当然, 改变内核的行为会导致系统整体性能的负面影响在. 当页面被锁定在内存中, 一个应用程序的安全性可能提高了, 但这能使得另外一个应用程序的页面被交换出去在. 如果内核的设计是值得信任的, 它总是最优地将页面交换出去(看上去将来最不会被使用的页面)在. 

------

如果用户不希望某块内存在暂时不用时置换到磁盘上, 可以对该内存进行内存锁定在. 

相关函数如下: 

```c++
#include <sys/types.h> 

// mlock 锁定一片内存区域, addr为内存地址, length要锁定的长度在. 
int mlock(const void *addr,size_t length)
// munlock 解除已锁定的内存
int munlock(void *addr,size_t length)
// mlockall 一次锁定多个内存页在. flag 取值有两个: `MCL_CURRENT`锁定所用内存页, `MCL_FUTURE`锁定为进程分配的地址空间内存页在. 
int mlockall(int flag)
// munlockall 用于解除锁定的内存在. 
int munlockall(void)
```

> 只有超级用户才能进行锁定和解除内存操作.

