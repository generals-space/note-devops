# tcpdump配合grep过滤

参考文章

1. [tcpdump | grep 时间间隔问题](http://blog.chinaunix.net/uid-29966814-id-4561116.html)

使用`tcpdump | grep`会出现时间间隔问题，大概隔一定的时间会跳出n条信息。
使用`2>&1`无效. 

原因在于`tcpdump`的管道是`buffered`，所以会出现这个问题。

解决办法是使用`-l`参数来取消`buffered`。

举例：

```
tcpdump -lni eth1 tcp and port 80 -s 0 -nnA | grep 'hao123'
```
