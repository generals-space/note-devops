# consul集群部署测试

参考文章

1. [服务发现 - consul 的介绍、部署和使用](https://www.jianshu.com/p/f8746b81d65d)
    - docker安装
2. [consul安装](http://blog.51cto.com/aaronsa/2064886)
    - 物理机安装

关于`consul`是做什么的就不说了, 关于ta和`zookeeper`, `etcd`等的比较也不说了, 关于`consul`的集群概念, 不就是一个`server`模式一个`client`模式吗? 也没什么可说的.

当前目录下的`docker-compose.yml`是根据参考文章1创建的, 3个server节点, 1个client节点, 访问任何一个节点的`8500`都可以进行交互, 不过web ui只在client节点上开启了. client的http端口映射到宿主上是10121, 所以访问路径为`http://localhost:10121/ui/dc1/services`

![](https://gitee.com/generals-space/gitimg/raw/master/88de748b2efc24b9caa6ae903aed2077.png)
