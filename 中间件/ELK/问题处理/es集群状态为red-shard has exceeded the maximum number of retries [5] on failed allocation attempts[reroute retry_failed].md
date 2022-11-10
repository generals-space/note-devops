# es集群状态为red-shard has exceeded the maximum number of retries [5] on failed allocation attempts

参考文章

1. [记一次ElasticSearch重启之后shard未分配问题的解决](https://www.cnblogs.com/hapjin/p/9726469.html)

es: 7.5.1

规格: master * 3 + data * 3

## 问题描述

某次测试环境主机宕机, 一个master与一个data脱离集群了, 挂了一个多小时. 

主机恢复后, es集群还是red. 进入 kibana 查看, 发现某个索引(有很多shard分片)没有恢复, 很多成对的主分片与副本未分配.

![](https://gitee.com/generals-space/gitimg/raw/master/2022/b0631066f22bdfe376fb8b01e05ec9cf.png)

## 解决方法

使用 explain 查询原因

```json
// GET _cluster/allocation/explain
{
    "index": "wechat-user",
    "shard": 0,
    "primary": true
}
```

输出如下

![](https://gitee.com/generals-space/gitimg/raw/master/2022/8e8ea92f4fa47cf4f39afa0669002318.png)

```
"explanation": "shard has exceeded the maximum number of retries [5] on failed allocation attempts - manually call [/_cluster/reroute?retry_failed=true] to retry, ...
```

这是由于这些分片分配的重试次数达到上限导致的失败, 此时主机已经恢复, 可以直接调用`/_cluster/reroute?retry_failed=true`手动重试, 可自动恢复, 不必人工干预.

```
POST _cluster/reroute?retry_failed=true
```

![](https://gitee.com/generals-space/gitimg/raw/master/2022/2a43594a2d91f6ecaa0ab7fb69afdf4a.png)

