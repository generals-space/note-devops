# 重启ES具体操作步骤

参考文章

1. [滚动重启](https://www.elastic.co/guide/cn/elasticsearch/guide/current/_rolling_restarts.html)

## 1. 重启前

### 1.1 查看并记录集群初始配置

查看并记录集群初始配置, 用于重启后恢复: 

```
curl -u 用户名:密码 -X GET 'localhost:9200/_cluster/settings?pretty'
```

![](https://gitee.com/generals-space/gitimg/raw/master/44d65fc6b234d2c7dba6e238974082ba.png)

- `persistent`: 永久生效
- `transient`: 临时生效

配置值一般格式: 

- `all`: 开启; 
- `none`: 禁用; 
- `null`: 取消配置, 即恢复默认. 

### 1.2 永久关闭分片分配、自动平衡

关闭分片分配会停止所有的分片动作, 以及分片的数据移动. 如果配置了关闭分片分配, 没有关闭自平衡, 也会在打开分片分配之后出现集群自平衡. 

```
curl -u 用户名:密码 -X PUT 'http://localhost:9200/_cluster/settings?pretty' -H 'Content-Type: application/json' -d '
{
  "persistent": {
    "cluster.routing.allocation.enable": "none",
    "cluster.routing.rebalance.enable" : "none"
  }
}'
```

![](https://gitee.com/generals-space/gitimg/raw/master/fa716068530dad3c8f824c75bcc86456.png)

### 1.3 验证配置结果

```
curl -u elastic:abcdef -X GET 'http://192.168.31.5:9200/_cluster/settings?pretty'
```

![](https://gitee.com/generals-space/gitimg/raw/master/866b5090a6bf355b64510979b2892437.png)

### 1.4 执行同步刷新

```
curl -u 用户名:密码 -X POST 'http://localhost:9200/_flush/synced?pretty'
```

![](https://gitee.com/generals-space/gitimg/raw/master/7ff57c5dc6206948a3c0b223c7fcf44f.png)

注意: failed全为0时, 同步刷新才执行成功. 

## 2. 重启后

### 2.1 查看进度

集群状态

```
curl -u 用户名:密码 -X GET 'http://localhost:9200/_cat/health?pretty&format=json'
```

![](https://gitee.com/generals-space/gitimg/raw/master/2bb2e65c5a18407b7e2b3852a6ea52ab.png)

分片恢复进度

```
curl -u 用户名:密码 -X GET 'http://localhost:9200/_cat/recovery?pretty'
```

![](https://gitee.com/generals-space/gitimg/raw/master/bfb9352a570d1b1e9aba1b2bd2a6796d.png)

### 2.2 打开分片分配. 

**注意**

需要当所有节点都已加入集群, 并恢复了其主要分片后(即`Yellow`状态, 且`_cat/health`得到的`relo`、`init`、`unassign`这3项都变成0), 再重新启用分配, 这样尽可能避免分片从远端恢复. 

```
curl -u 用户名:密码 -X PUT 'http://localhost:9200/_cluster/settings?pretty' -H 'Content-Type: application/json' -d '
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}'
```

![](https://gitee.com/generals-space/gitimg/raw/master/e0cc10f6945df0d32af074dce963d439.png)

### 2.3 集群Green后, 恢复初始配置
