# es安全认证.2.集群

参考文章

1. [干货 | Elasticsearch 7.1免费安全功能全景认知](https://blog.csdn.net/laoyang360/article/details/90554761)
    - es 安全机制的演变历程
2. [<十三>ELK-学习笔记–elasticsearch-7.x使用xpack进行安全认证](http://www.eryajf.net/3500.html)
    - 单机与集群环境开启安全认证的实际操作示例.
    - ES中内置了几个管理其他集成组件的账号: apm_system, beats_system, elastic, kibana, logstash_system, remote_monitoring_user
    - kibana密文密码

集群认证不能单纯只打开`xpack.security.enabled`就行了, 还有其他的一些配置. 如果不添加的话, 不管有没有配置 es 的用户名密码(通过环境变量), 集群都无法 setup 成功. 每个节点都无法与其他节点通信, 也无法提供服务, 日志中报如下错误.

```
{"type": "server", "timestamp": "2020-06-23T01:47:45,296+0000", "level": "WARN", "component": "o.e.c.c.ClusterFormationFailureHelper", "cluster.name": "elasticsearch", "node.name": "es-cluster-0",  "message": "master not discovered yet, this node has not previously joined a bootstrapped (v7+) cluster, and this node must discover master-eligible nodes [es-cluster-0, es-cluster-1, es-cluster-2] to bootstrap a cluster: have discovered []; discovery will continue using [10.254.2.48:9300, 10.254.0.14:9300] from hosts providers and [{es-cluster-0}{wljrcTblRPezZeFrEb1q0Q}{QBUpHL5IQtmWqh91xJOs3g}{10.254.1.58}{10.254.1.58:9300}{ml.machine_memory=2964783104, xpack.installed=true, ml.max_open_jobs=20}] from last-known cluster state; node term 0, last-accepted version 0 in term 0"  }
```

集群间的认证是通过密钥完成的(同etcd).

如下两条命令均一路回车即可, 不需要给秘钥再添加密码

```
/usr/share/elasticsearch/bin/elasticsearch-certutil ca
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
```

默认会在`/usr/share/elasticsearch/`目录下, 分别生成`elastic-stack-ca.p12`和`elastic-certificates.p12`文件. 可以使用`-out`选项指定生成的文件路径, 如下

```
/usr/share/elasticsearch/bin/elasticsearch-certutil ca -out /tmp/xxx-ca.p12
```

其实之后在配置文件中只会用到`elastic-certificates.p12`, 不需要`elastic-stack-ca.p12`, 所以上述命令可以只执行第2步, 不需要生成ca文件.

```yaml
## 这条配置表示开启xpack认证机制
xpack.security.enabled: true 
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/elastic-certificates.p12
```

上述配置可以与用户名密码一同设置, 这样对 setup 的集群也可以生效.
