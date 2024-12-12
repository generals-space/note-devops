# Linux-stress服务器性能测试

参考文章

1. [Linux stress 命令](https://www.cnblogs.com/sparkdev/p/10354947.html)

申请内存并占用(不会频繁释放)

```
stress --vm 4 --vm-bytes 1000M --vm-keep
```

4个进程, 每个申请1G.
