# ip tunnel无法删除通道设备ipip-Operation not permitted

参考文章

1. [Linux删除tunnel的方法](https://www.cnblogs.com/snooker/p/9945863.html)
    - 删除`ipip`设备的方法

calico使用ipip网络模型时会创建一个`tunl0`网络接口, 但是将calico组件移除后, 这个接口仍然被保留. 使用`ip link del tunl0`删除时无效, 且`tunl0`的ip仍然能被ping通. 而使用`ip tunnel del tunl0`时则报如下错误

```console
$ ip tunnel del tunl0
delete tunnel "tunl0" failed: Operation not permitted
```

按照参考文章1中所说, 卸载ipip内核模块经验证可行.

```console
$ lsmod | grep ipip
ipip                   16384  0
tunnel4                16384  1 ipip
ip_tunnel              24576  1 ipip
$ modprobe -r ipip
```
