# es-[unavailable_shards_exception] at least one primary shard for the index [.security-7] is unavailable

参考文章

1. [es-At least one primary shard for the index [.security-7] is unavailable](https://discuss.elastic.co/t/at-least-one-primary-shard-for-the-index-security-7-is-unavailable/249508)
2. [Fresh cluster all shards are unavailable](https://discuss.elastic.co/t/fresh-cluster-all-shards-are-unavailable/210216)
3. [ElasticSearch 开发总结（三）——Unavailable Shards Exception解决思路](https://blog.csdn.net/huoqilinheiqiji/article/details/86004653)

ES集群节点几乎全部宕机, 访问 master-0 节点的 es api 时, 报了如下错误

```
{
    "error" : {
        "root_cause" : [
            {
                "type" : "unavailable_shards_exception",
                "reason" : "[.security-7][0] [shardIt], [0] active : Timeout waiting for [1m], request: indices:data/write/update"
            }
        ],
        "type" : "unavailable_shards_exception",
        "reason" : "[.security-7][0] [shardIt], [0] active : Timeout waiting for [1m], request: indices:data/write/update"
    },
    "status" : 503
}
```

同时集群日志里也出现了如下报错

```
org.elasticsearch.action.UnavailableShardsException: at least one primary shard for the index [.security-7] is unavailable
	at org.elasticsearch.xpack.security.support.SecurityIndexManager.getUnavailableReason(SecurityIndexManager.java:181) ~[x-pack-security-7.9.0.jar:7.9.0]
	at org.elasticsearch.xpack.security.authz.store.NativePrivilegeStore.innerGetPrivileges(NativePrivilegeStore.java:185) [x-pack-security-7.9.0.jar:7.9.0]
....
org.elasticsearch.action.search.SearchPhaseExecutionException: all shards failed
	at org.elasticsearch.action.search.AbstractSearchAsyncAction.onPhaseFailure(AbstractSearchAsyncAction.java:551) [elasticsearch-7.9.0.jar:7.9.0]
...
org.elasticsearch.action.NoShardAvailableActionException: No shard available for [get [.kibana][_doc][space:default]: routing [null]]
...
[2020-09-21T21:23:54,004][INFO ][o.e.c.r.a.AllocationService] [Innode] Cluster health status changed from [RED] to [YELLOW] (reason: [shards started [[.kibana_task_manager_1][0]]]).
[2020-09-21T21:24:17,331][INFO ][o.e.c.m.MetadataIndexTemplateService] [Innode] adding template [.management-beats] for index patterns [.management-beats]
........
```

当然 kibana 也连接不了了.

由于集群还开着 xpack 认证, 所以先把 xpack 关了, 把集群又重启了下(反正集群都散了). 然后通过 curl 查询 es api, 发现所有索引都 red 了.

使用`GET /索引名`, 还是能查到索引的字段信息的, 但是`GET /索引名/_search`查询内容时, 得到了如下报错

```
{
    "error" : {
        "root_cause" : [ ],
        "type" : "search_phase_execution_exception",
        "phase" : "all shards failed",
        "grouped" : true,
        "failed_shards" : []
    },
    "status" : 503.
}
```

> `kibana`在尝试连接 ES 集群时, ES日志也报的也是类似的日志.

这种情况几乎就是没救了.

