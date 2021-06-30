# zkCli命令行操作

参考文章

1. [【分布式】Zookeeper使用--命令行](https://www.cnblogs.com/leesf456/p/6022357.html)
2. [ZooKeeper客户端 zkCli.sh 节点的增删改查](https://www.cnblogs.com/sherrykid/p/5813148.html)

zk启动后, 就可以使用`bin/zkCli.sh`进入交互式终端进行操作了.

```
./bin/zkCli.sh -server 127.0.0.1:2181
```

> 注意: `-server`中只有一个短横线.

输入`help`可以查看所有可用命令.

## 查询

- `ls /`: 可以查看当前目录下所有节点列表, 但不包括这些节点下各自的子节点.
- `get /node`: 可以查看目标节点中的内容(其实不只是内容, 还包括版本号, 创建时间, 子节点数量等信息).
- `ls2 /node`: 作用等同于`get /node`.

## 创建

## 更新

## 删除

- `delete /node`: 删除目标节点, 不过仅限于该节点下没有子节点的情况.
    - 目标节点拥有子节点时, 报错为: "Node not empty: /testxxx"
- `rmr /node`: 可删除拥有子节点的节点.
