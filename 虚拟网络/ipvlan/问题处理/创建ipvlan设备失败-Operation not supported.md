# 创建ipvlan设备失败-Operation not supported

ip link add link ens34 ipvlan1 type ipvlan mode l3

```
RTNETLINK answers: Operation not supported
```

看了下, 应该是因为内核版本不够高.

```
$ uname -a
Linux k8s-worker-01 3.10.0-1062.4.1.el7.x86_64 #1 SMP Fri Oct 18 17:15:30 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```

`ipvlan`是 linux kernel 比较新的特性, linux kernel 3.19 开始支持 ipvlan, 但是比较稳定推荐的版本是 >=4.2（因为 docker 对之前版本的支持有 bug）,具体代码见内核目录：`/drivers/net/ipvlan/`
