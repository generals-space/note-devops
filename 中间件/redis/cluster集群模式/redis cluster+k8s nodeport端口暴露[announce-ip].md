# redis cluster+k8s nodeport端口暴露[announce-ip]

参考文章 

1. [暴露redis-cluster到k8s集群外部.md](https://blog.csdn.net/ll577644332/article/details/124797984)
    - `config write`可以将通过`redis-cli`修改的配置项写入到`redis.conf`配置文件中.

redis: v6.2.12

假设k8s集群中存在一个redis cluster集群(三主三从), 各redis pod容器IP如下

- pod-0: 172.22.248.30
- pod-1: 172.22.248.31
- pod-2: 172.22.248.32
- pod-3: 172.22.248.33
- pod-4: 172.22.248.34
- pod-5: 172.22.248.35

宿主机有3台

- 192.168.30.4
- 192.168.30.5
- 192.168.30.6

现在希望能够在k8s集群外部通过`jedis`等客户端进行连接, 但通过常规的 nodeport service 进行端口暴露其实是存在问题的.

在写入/读取数据时, 由于 slot 是分布在不同节点上的, 所以不一定直接命中, redis 会返回目标 key 的实际位置

```
set key01 value01
- MOVED 13770 172.22.248.33
```

但麻烦是, 这个位置是用**容器IP**表示的.

猜测 jedis 也是这套逻辑: 

```
           写入成功
尝试写入 -> 
           写入失败, 得到实际位置 -> 再次写入 -> 写入成功
```

但是 jedis 是无法直接连接到容器IP`172.22.248.xxx`的, 有什么办法在写入失败时, 让 redis 返回的实际位置也用"宿主机IP+nodeport"表示呢?

参考文章1中提到了如下3个配置.

```
cluster-announce-ip 192.168.30.4
cluster-announce-port 30679
cluster-announce-bus-port 31679
```

这3个配置要在**所有节点**上都执行一遍才有效.

> 注意: 不同节点暴露的端口是不同的.

然后所有节点的`cluster nodes`信息都会发生变化, 会变成`$cluster-announce-ip:$cluster-announce-port@cluster-announce-bus-port`.

不过, 在k8s集群内部还是可以用各节点的容器IP连接的.
