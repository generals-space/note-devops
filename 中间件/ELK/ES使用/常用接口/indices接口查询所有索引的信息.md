# indices接口查询所有索引的信息

查看集群内**所有索引**信息, 包含各索引的名称(index), 状态, 信息数量及索引数据大小等信息.

```
$ curl -u elastic:changeme localhost:9200/_cat/indices
green open .monitoring-kibana-6-2020.11.03 45fvV3uEROWwL36Xzl0QXw 1 1   226  0 274.8kb 137.4kb
green open .triggered_watches              pTQ4Wmh6SHW_psDwUf7X3w 1 1     0  0  46.9kb  23.4kb
green open .watches                        Vp4K3lYHRxiNcmtI-4_4EA 1 1     4  0 126.8kb  63.4kb
green open .watcher-history-3-2020.11.02   Njh5tw2dSx65bDlagR3p_Q 1 1   646  0     1mb 559.3kb
```

在重启 es data 节点的时候, 集群可能由于恢复索引变成 yellow, 在这个过程中, 可以通过此接口查看各索引的状态.
