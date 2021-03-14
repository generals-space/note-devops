# es集群状态为red-Unassigned Replica 数据丢失

参考文章

1. [elasticsearch集群节点重启导致分片丢失的问题](https://blog.csdn.net/w1346561235/article/details/105852936/)
2. [Cluster Reroute](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/cluster-reroute.html)
    - 官方文档
3. [【重新分配分片】Elasticsearch通过reroute api重新分配分片](https://blog.51cto.com/lookingdream/2090873)

es: 5.5.0, 规格为 master * 3 + data * 3(master 也可做 data 用)

## 问题描述

这次遇到的与参考文章1中所说的几乎完全一致, 重启 es 集群时, 有些主机网络出了点问题, 当然 es 集群也没法正常使用了. 后来主机网络修复后, es 集群就一直是 red 状态, 再也无法恢复了.

![](https://gitee.com/generals-space/gitimg/raw/master/3525a664ac9f2e3d305e34ef27a44278.png)

使用`explain`接口查询原因.

```json
GET /_cluster/allocation/explain
{
    "index": "索引名",
    "shard": 分片id(整型数值),
    "primary": 是否为主分片(true/false)
}
```

![](https://gitee.com/generals-space/gitimg/raw/master/9279a599b02b1177dea8b0fcfd743ca5.png)

原因如下

```
cannot allocate because a previous copy of the primary shard existed but can no longer be found on the nodes in the cluster
```

按照参考文章1中的说法, 分片没有分配是因为在集群上没有找到对应分片的文件. 不过作者貌似还挺怀疑的, 毕竟3个分片, 每个分片都有一主一从的副本, 不可能`primary`和`replica`都丢了, 同样日志是没有错误的(毕竟之前是主机的问题).

响应的`store`字段, `"found": false`表示没有找到分片的任何segment文件. 如果能找到分片较旧的segment, 这里会显示对应陈旧的`allocate id`的内容. 

```json
"store": {
    "found": false
}
```

不过这里连旧的`segment`都找不到了, 所以才显示`false`, 但是按照参考文章1中提供的另一个接口`/_status/state`发起请求. 

```json
GET _cluster/state?filter_path=metadata.indices.索引名.in_sync_allocations.*
```

响应也与文章中比较相似.

![](https://gitee.com/generals-space/gitimg/raw/master/57209e2dd46d76e76861225643311268.png)

## 重新分配

解决的方法没有实际操作, 因为那个集群并不是我负责的. 不管怎么操作, 丢失的分片就真的丢失了, 无法恢复.

对`unassigned`的分片重新分配空的内容, 即使后来再通过任何方法把分片找回来, es也会将后来找到的内容 delete 并 overwrite. 因为es会认为, 后来分配的空分片的内容是较新的. 

重新分配分片使用reroute API, reroute接受两种操作: 

1. `allocate_stale_primary`: 以集群内存在的陈旧的分片内容, 再次分配. 
2. `allocate_empty_primary`: 分配空内容的分片

这两种都会造成数据丢失, es出于提醒用户的目的, 因此专门需要指定`"accept_data_loss": true`. 另外就是指定索引名称、要分配的分片id、和要将分片分配到的节点名称, 这里只指定`primary`分片, replicat分片会自动找节点存储. 

```json
POST /_cluster/reroute
{
    "commands" : [
        {
            "allocate_stale_primary" : {
                "index" : "索引名", 
                "shard" : 分片id, // 整型数值
                "node" : "目标主机id",
                "accept_data_loss": true
            }
        }
    ]
}
```

### 

不过我还是在本地尝试了一下这个接口的使用方法. 在重新分配分片之前, 分片分布如下

![](https://gitee.com/generals-space/gitimg/raw/master/bd134e8de5cca3abee082a60f535a32b.png)

可以看到, 分片0, 1在节点`esc-data-1`上, 而分片2, 3, 4则在`esc-data-0`上.

> 只有主分片, 没有副本(之前手动改的)

我们尝试将分片2分配到`esc-data-1`节点上.

```json
POST /_cluster/reroute
{
    "commands" : [
        {
            "allocate_stale_primary" : {
                "index" : "nginx-log-2020.09.16", 
                "shard" : 2,
                "node" : "esc-data-1",
                "accept_data_loss": false
            }
        }
    ]
}
```

> 由于是对完整的索引进行分片重新分配, 并不是为了修复什么问题, 所以这里将`accept_data_loss`字段置为`false`.

参考文章1提到了2个操作`allocate_stale_primary`, `allocate_empty_primary`, 但这两个其实是针对集群中存在异常的索引而做的, 我所实验的索引一切正常, 这导致在发起上面的请求时出现了如下错误

```json
{
  "error": {
    "root_cause": [
      {
        "type": "remote_transport_exception",
        "reason": "[esc-master-2][172.18.0.2:9300][cluster:admin/reroute]"
      }
    ],
    "type": "illegal_argument_exception",
    "reason": "[allocate_stale_primary] primary [nginx-log-2020.09.16][2] is already assigned"
  },
  "status": 400
}
```

ta说分片2已经存在于集群中的某个节点, 不需要做这样的操作.

于是我就又找了找有没有移动切片的方法, 从参考文章2(官方文档)中找到, `reroute`接口其实有5种操作, 多出来的3个是

1. `move`: 把分片从一节点移动到另一个节点, 可以指定索引名和分片号. 
2. `cancel`: 取消分配一个正在分配的分片. 可以指定索引名和分片号. node参数可以指定在那个节点取消正在分配的分片, `allow_primary`参数支持取消分配主分片. 
3. `allocate_replica`: 分配一个未分配的分片到指定节点, 可以指定索引名和分片号, `node`参数指定分配到那个节点, `allow_primary`参数可以强制分配主分片, 不过这样可能导致数据丢失. (一般用来清空某个未分配分片的数据的时候才设置这个参数)

上面3个参数的说明来自参考文章3, 不过这篇文章中写到, 对于未分配的分片, 可以使用`allocate_replica`操作进行分配, 却没有提到`allocate_stale_primary`, `allocate_empty_primary`, 不知道实际情况应该按哪种. 

```json
POST /_cluster/reroute
{
    "commands" : [
        {
            "move" : {
                "index" : "nginx-log-2020.09.16", 
                "shard" : 2,
                "from_node": "esc-data-0",
                "to_node" : "esc-data-1"
            }
        }
    ]
}
```

> `move`操作不支持`accept_data_loss`参数.

响应为

```json
{
  "acknowledged": true,
  "state": {
      // 省略
  }
```

再次查看分片分布

![](https://gitee.com/generals-space/gitimg/raw/master/d9246ba48cfe813388dec6c6e60fd7e5.png)

