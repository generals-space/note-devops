# du -sh找不到大文件[lsof -n]

参考文章

1. [linux磁盘空间被占满，但是找不到大文件](https://www.cnblogs.com/healthinfo/p/12402139.html)
2. [Linux大文件已删除，使用df查看已使用的空间并未减少](https://www.cnblogs.com/5201351/p/4281405.html)

有时使用`df -h`查看磁盘, 发现已经100%了, 但是使用`du -sh ./*`又找不到大文件.

这种情况有可能是因为删除了一个正在被某个进程使用的大文件, 比如`zookeeper.out`. 导致虽然使用`ls`已经看不到该文件了, 但是OS还是不能将其占用的究竟释放掉, 因为进程还在.

可以使用如下命令查看是哪个文件被删除但还在使用的.

```
lsof -n | grep delete
```

输出结果如下

```log
root@hua-dlzx1-a0203-gyt:[/root]lsof -n | grep delete
gssproxy    1288         root  txt   REG  253,0      133736  218243639 /usr/sbin/gssproxy (deleted)
gssproxy    1288   1322  root  txt   REG  253,0      133736  218243639 /usr/sbin/gssproxy (deleted)
gssproxy    1288   1323  root  txt   REG  253,0      133736  218243639 /usr/sbin/gssproxy (deleted)
java      487378         root   1w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
java      487378         root   2w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
SendWorke 487378 326518  root   1w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
SendWorke 487378 326518  root   2w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
RecvWorke 487378 326519  root   1w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
RecvWorke 487378 326519  root   2w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
LearnerCn 487378 473427  root   1w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
LearnerCn 487378 473427  root   2w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
java      487378 487381  root   1w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
java      487378 487381  root   2w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
VM        487378 487382  root   1w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
VM        487378 487382  root   2w   REG  253,0 75708653568  168078850 /data/zk-flink-1/zookeeper.out (deleted)
```

找到那个zookeeper进程, 重启一下就可以了.

对于不重启进程又能释放的方法, 目前还没有...
