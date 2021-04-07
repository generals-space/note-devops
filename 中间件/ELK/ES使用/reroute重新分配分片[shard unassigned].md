# reroute重新分配分片[shard]

参考文章

1. [elasticsearch多磁盘扩容](https://blog.csdn.net/illbehere/article/details/78202973)
    - 负载过高可能会导致个别分片长期处于`UNASSIGNED`状态
2. [Cluster Reroute](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/cluster-reroute.html)

ES: 5.5.0

ES集群在某两个data节点的内存占用过高后(持续测试了20分钟左右), 状态变为`yellow`, 在kibana中查看时发现是因为有些分片的副本处于`unassigned`状态了.

![](https://gitee.com/generals-space/gitimg/raw/master/2d1a49fbf1dfe735f36969546bfa897b.jpg)

![](https://gitee.com/generals-space/gitimg/raw/master/db2400a20171d49823a270a4b702593a.jpg)

为了恢复, 需要手动分配出现问题的分片, 我们需要知道分片id.

![](https://gitee.com/generals-space/gitimg/raw/master/11fe77eaa64878fdc752fd7d7ea9e080.jpg)

![](https://gitee.com/generals-space/gitimg/raw/master/c3b67f74b9357e46e390e1553e1e4f22.jpg)

## 分配方法

副分片

```
curl -XPOST "http://xxxx:9200/_cluster/reroute" -d '{
  "commands" : [ {
        "allocate_replica" :
            {
              "index" : "索引名称", "shard" : 4, "node" : "node56"
            }
        }
  ]
}'
```

默认情况下只允许手动分配副本分片(即使用`allocate_replica`), 所以如果要分配主分片, 需要单独加一个`accept_data_loss`选项

主分片

```
curl -XPOST "http://xxxx:9200/_cluster/reroute" -d '{
  "commands" : [ {
        "allocate_stale_primary" :
            {
              "index" : "索引名称", "shard" : 4, "node" : "node56", "accept_data_loss" : true
            }
        }
  ]
}'
```

------

上面的`allocate_stale_primary`是已知该主分片原来的位置是"node56", 这样在`reroute`时, 数据一般不会丢失. 

但是如果没有记录, 随意分配主分片, 或是主分片确认已丢失, 可能需要使用`allocate_empty_primary`.

```
curl -XPOST "http://xxxx:9200/_cluster/reroute" -d '{
  "commands" : [ {
        "allocate_empty_primary" :
            {
              "index" : "索引名称", "shard" : 4, "node" : "node56", "accept_data_loss" : true
            }
        }
  ]
}'
```

这是分配了一个空的主分片到"node56"上.
