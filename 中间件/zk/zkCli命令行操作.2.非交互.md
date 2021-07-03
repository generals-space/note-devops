# zkCli命令行操作

参考文章

1. [【分布式】Zookeeper使用--命令行](https://www.cnblogs.com/leesf456/p/6022357.html)
2. [ZooKeeper客户端 zkCli.sh 节点的增删改查](https://www.cnblogs.com/sherrykid/p/5813148.html)

```
./bin/zkCli.sh ls /
```

> 注意: 这种方法无法显示`watch`的信息, 要通过`watch`监听一个节点的变动, 只能在交互式命令行完成.

