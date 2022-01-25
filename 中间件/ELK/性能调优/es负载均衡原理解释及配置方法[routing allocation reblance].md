# es负载均衡原理解释及配置方法

参考文章

1. [ES踩坑——提高写入性能之集群负载均衡](https://blog.csdn.net/wx1528159409/article/details/106200978)
2. [elasticsearch 重启后数据平衡问题](https://elasticsearch.cn/question/5376)
    - 这个案例还没看, 先收藏

当文档id, 即`_id`被指定的情况下, 由于每条文档往ES写入时, 会对`_id`进行hash分配其写到哪个节点的主分片上, 这样有可能出现写偏了的情况, 即集群某台节点的负载特别高, 所以一般建议_id让ES自动设置.

> redis 的哈希槽(slot)就是为了避免类似的情况而出现的

这样, 在写入的时候, 当集群某台节点负载特别高时, 集群会自动进行负载均衡, 将某个数据量异常大的主分片数据迁移至其他分片.

但是这个负载均衡过程是很耗集群写入性能的, 当多份数据往集群写入时, 有可能因为集群的负载均衡占用太多资源, 导致写入速率过慢.

这种情况可以设置某个时间段, 关闭集群负载均衡, 任务写完后再打开负载均衡. 只要集群机器能承载的住, 将所有资源都用来写数据, 提高写入性能.

- all: 开启；
- none: 禁用(GET _cluster/settings可查看该项配置)；
- null: 禁用（GET _cat/settings看不到该项配置） 

```json
PUT _cluster/settings 
{ 
    "persistent": {
        "cluster": { 
            "routing": { 
                "allocation": { 
                    "enable": "all"/"none"/"null"
                }, 
                "reblance": { 
                    "enable": "all"/"none"/"null"
                } 
            } 
        } 
    }
}
```
