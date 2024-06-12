# zkCli命令行操作

参考文章

1. [掌握 zookeeper 命令，这篇文章就够了](https://blog.csdn.net/feixiang2039/article/details/79810102)
2. [zookeeper watch java_zookeeper watch机制的理解](https://blog.csdn.net/weixin_28766939/article/details/114121835)
    - `watch`是异步的, 即发起端收到修改成功的通知之前, 订阅端就已经收到节点变动的通知了.
    - 但是zk保证了订阅端在收到通知之前, 查询目标节点的信息时, 一定不会是变动后的值.
    - watch是一次性触发器, 如果你得到了一个watch事件, 而你希望在以后发生变更时继续得到通知, 你应该再设置一个watch
    - 一个设置了watch的客户端连接断开时, 服务端会将ta的watch移除, ta再次连接上时, 需要重新设置watch.

zk: 3.4.10

在`zkCli.sh`交互式界面中输入`help`, 可以查看可用的命令列表, 其中带有`watch`字段的即为可以监听的方法, 一般有如下几种:

1. `ls path [watch]`
2. `ls2 path [watch]`
3. `get path [watch]`
4. `stat path [watch]`

**⚠注意:**

1. 要通过`watch`监听一个节点的变动, 只能在交互式命令行完成.
2. `watch`监听是一次性的, 触发过一次后就不再生效了, 再次监听只能重复注册.
3. `watch`只监听目标节点, 不关心子节点(的更新操作).

## `ls`,`ls2`与`NodeChildrenChanged`事件

`ls`与`ls2`类似, ta们可以查询目标节点的元信息, 但主要目的是打印出目标节点的子节点列表. 

同样, 在监听一个节点时, ta们只关心目标节点下面的子节点变动, 不关注目标节点本身的变化.

所以能触发`ls`与`ls2`的回调行为的, 是`create`和`delete`操作.

```log
[zk: localhost:2181(CONNECTED) 3] ls /node watch
/node
cZxid = 0x200004e37
...
[zk: localhost:2181(CONNECTED) 3] delete /node/SubNode

WATCHER::

WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/node
```

## `get`,`stat`与`NodeDataChanged`事件

`get`与`stat`类似, ta们只查询目标节点的元信息, 不打印节点的子节点列表. 

同样, 在监听一个节点时, ta们也不关心目标节点下面的子节点变动, 只关注目标节点本身的变化.

所以能引发`get`与`stat`的回调行为的, 是`set`更新操作

```log
[zk: localhost:2181(CONNECTED) 3] get /node watch
/node
cZxid = 0x200004e37
...
[zk: localhost:2181(CONNECTED) 3] set /node NewValue

WATCHER::

WatchedEvent state:SyncConnected type:NodeDataChanged path:/node
```

## `NodeDeleted`事件

有一种事件, 是`ls/ls2`与`get/stat`都会监听到的, 那就是节点删除, 且是目标节点被删除, 而非其子节点的删除.

```log
[zk: localhost:2181(CONNECTED) 3] get /node watch
/node
cZxid = 0x200004e37
...
[zk: localhost:2181(CONNECTED) 3] delete /node 

WATCHER::

WatchedEvent state:SyncConnected type:NodeDeleted path:/node
```

