参考文章

1. [Tune for indexing speed](https://www.elastic.co/guide/en/elasticsearch/reference/7.5/tune-for-indexing-speed.html#tune-for-indexing-speed)
    - ES调优手段:
        - bulk request
        - swap 
        - 堆外内存(文件缓存(至少一半))
        - 自生成id
        - indices.memory.index_buffer_size
