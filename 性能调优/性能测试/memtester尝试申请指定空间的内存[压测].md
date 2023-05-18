# memtester尝试申请指定空间的内存[压测]

参考文章

1. [内存压测神器:memtester深度指南](https://blog.51cto.com/u_14900374/2533353)
2. [Memtester?](https://forums.raspberrypi.com/viewtopic.php?t=211648)
    - memtester 的执行需要 root 权限, 如果是在 kube/docker 容器中, 则需要 privileged 特权.

memtester 可以精确地向OS申请指定空间的内存, 用作压测, 或者 cgroup 内存限制是否成功的验证工作.

```
memtester 1024m 1
```

表示向OS申请1G内存, 并进行1次验证

> 末尾的参数1表示检测内存状态与性能的次数, 类似于循环压测, 这里不详细描述.

