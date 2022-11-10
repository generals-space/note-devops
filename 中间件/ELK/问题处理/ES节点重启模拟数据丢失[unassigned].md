# ES节点重启模拟数据丢失[unassigned]

参考文章

1. [elasticsearch集群节点重启导致分片丢失的问题](https://blog.csdn.net/w1346561235/article/details/105852936/)
    - 发生数据丢失的话, 手动分配分片也是不成功的, 会报如下错误
    - "cannot allocate because a previous copy of the primary shard existed but can no longer be found on the nodes in the cluster"
2. [断电或重启集群elasticsearch，你所需要做的事！](https://blog.csdn.net/qq_23160237/article/details/86703678)
3. [谁再问elasticsearch集群Red怎么办？把这篇笔记给他](https://aijishu.com/a/1060000000085558)

本文模拟ES分片数据丢失的场景, 不是未分配, 而是真正的丢失.

- ES版本: v5.5.0
- 集群规格: master x 3 + data x 1(其中master也可以作为data存储数据)

首先向集群中创建如下索引, **索引分片数量 > Node节点数量**.

```json
PUT article
{
    "settings": {
      "index": {
        "number_of_shards": "5",
        "number_of_replicas": "1"
      }
    }
}
```

![](https://gitee.com/generals-space/gitimg/raw/master/1c14f30d290b1ae8ef0330f7b96a3b5c.png)

我们先停止master-0和master-1(可以通过设置较大的`requests`+`OnDelete`更新策略模拟资源不足去实现), 这样`article`的**分片1和2**就会丢失. 剩下的master-2和data-0节点, 会出现异常(由于`discovery.zen.minimum_master_nodes: 2`的存在, 至少2个master才能组成集群).

![](https://gitee.com/generals-space/gitimg/raw/master/37d7bfb5ed7d6e70c1580f28940e0fbe.png)

此时, 集群是无法访问的, head服务自然也连接不上, data-0的日志会有如下输出

```
[2021-12-20T15:52:42,249][WARN ][o.e.c.NodeConnectionsService] [xxx-es-1220-01-data-0] failed to connect to node {xxx-es-1220-01-master-1}{1rMaMVGHSIa6IBdS-RnL4Q}{vPinPOG6SOm5Gy631KwRwQ}{192.168.34.219}{192.168.34.219:9311}{ml.enabled=true} (tried [241] times)
org.elasticsearch.transport.ConnectTransportException: [xxx-es-1220-01-master-1][192.168.34.219:9311] handshake failed. unexpected remote node {xxx-es-1220-01-master-1}{1rMaMVGHSIa6IBdS-RnL4Q}{jrSJt5qoTDint5cvfNF2Qg}{192.168.34.219}{192.168.34.219:9311}{ml.enabled=true}
    ...省略
[2021-12-20T15:52:43,390][WARN ][o.e.d.z.ZenDiscovery     ] [xxx-es-1220-01-data-0] not enough master nodes discovered during pinging (found [[Candidate{node={xxx-es-1220-01-master-1}{1rMaMVGHSIa6IBdS-RnL4Q}{jrSJt5qoTDint5cvfNF2Qg}{192.168.34.219}{192.168.34.219:9311}{ml.enabled=true}, clusterStateVersion=-1}]], but needed [2]), pinging again
```

上面的日志说到, 还差一个master节点, 于是尝试连接master-1, 但是失败了(为啥不是master-0呢🤔)

等待10分钟, 我们将master-1启动, 再次访问head.

![](https://gitee.com/generals-space/gitimg/raw/master/37e4acf6a339f8b609f225ec4c761d28.png)

此时`article`索引的**分片1和2**已经丢失了, 且无法找回, 查看原因, 显示"no_valid_shard_copy"(这是连副本也没了, 无法修复的).

![](https://gitee.com/generals-space/gitimg/raw/master/b2618d25f95744b5367b7cd1788b37da.png)

此时我们把剩下的master-0也启动起来, 结果仍然不行.

![](https://gitee.com/generals-space/gitimg/raw/master/a62018eb404e98abcccf9663056d486c.png)

后来我尝试将所有节点都重启了一下, 也没能再恢复了, 看来是真的丢了.

## 总结

这个场景有其特殊性, 之后再总结吧.
