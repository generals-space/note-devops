参考文章

1. [Elasticsearch集群规划及性能优化实践（笔记）](https://blog.csdn.net/shen2308/article/details/108548347)
    - 集群规模评估
    - 索引配置评估
    - ES集群写入性能优化
    - 常见分片未分配原因总结
2. [[译]使用explain API摆脱ElasticSearch集群RED苦恼](https://segmentfault.com/a/1190000008956708)
    - 新建索引与已有索引的分片分配过程是不同的.
3. [ES踩坑——提高写入性能之集群负载均衡](https://blog.csdn.net/wx1528159409/article/details/106200978)
    - 两套不同的ES集群, 配置参数是不同的, 所以可能会出现两套ES集群, 性能好的集群数据写入反倒比性能差的集群更慢的情况, 
    - 当没有别的优化点可以做时, 可以考虑优化集群配置参数, 比如降低磁盘使用的阈值、降低集群负载均衡频率等.

