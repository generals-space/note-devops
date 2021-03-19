# redis-SELinux导致主从设置不生效

参考文章

1. [Redis Slave Master connections fails Slave logs show: Unable to connect to MASTER: Permission denied](http://stackoverflow.com/questions/34906127/redis-slave-master-connections-fails-slave-logs-show-unable-to-connect-to-maste)

### 问题描述

在`cli`中执行`slaveof 172.16.1.100 6379`, 希望其将`172.16.1.100`中的数据同步到本地. 但是不生效, 而且再执行`set key1 'val1'`, 竟然返回`OK`. 要知道作为从节点的服务是不可写的.

查看日志, 显示

```
[20671] 12 Jan 15:48:02.369 * Connecting to MASTER 172.16.1.100:6379 [20671] 12 Jan 15:48:02.369 # Unable to connect to MASTER: Permission denied
```

### 原因分析及解决

SELinux的问题, 需要将远程redis所再主机连同本地主机的SELinux都关闭.
