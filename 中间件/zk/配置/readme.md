参考文章

1. [zookeeper集群应对万级并发的调优](https://blog.csdn.net/lifetragedy/article/details/116641678)
2. [ZooKeeper客户端连接数过多](https://blog.csdn.net/zlfprogram/article/details/74066792)
    - `maxClientCnxns`单个客户端与单台服务器之间的连接数的限制, 是ip级别的, 默认是60, 如果设置为0, 那么表明不作任何限制. 
    - 请注意这个限制的使用范围, 仅仅是单台客户端机器与单台ZK服务器之间的连接数限制, 不是针对指定客户端IP, 也不是ZK集群的连接数限制, 也不是单台ZK对所有客户端的连接数限制. 

