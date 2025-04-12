# nc实现端口转发[forward]

参考文章

1. [使用 nc（netcat）命令实现端口流量转发](https://blog.csdn.net/qq_14829643/article/details/134346394)

```bash
#!/bin/bash

while true; do
{ 
    echo "Connection received"; 
    nc -c "nc 10.76.68.76 8848" 
} | nc -lk 8848
done
```

这个脚本的工作原理如下：

- 外层的 while true; do ... done 循环确保脚本持续运行，即使在单个连接关闭之后。
- { ... } | nc -lk 8848 是一个命令块，它会在本机的8848端口上启动 nc 并监听该端口。
- echo "Connection received" 仅为示例，表示每当有新连接时，它会显示一条消息。您可以根据需要修改或删除这个echo命令。
- nc -c "nc 10.76.68.76 8848" 是关键部分。这里，-c 选项允许指定要执行的命令。当有数据到达时，这个命令会启动一个新的 nc 进程，将数据转发到10.76.68.76上的8848端口，并将响应返回给原始请求者。

------

```
socat TCP-LISTEN:9090,fork TCP:192.168.11.2:9090
```

- `TCP-LISTEN:9090`表示监听本地9090端口
- `192.168.11.2:9090`表示接收到请求后将数据包转发到192.168.11.2:9090

