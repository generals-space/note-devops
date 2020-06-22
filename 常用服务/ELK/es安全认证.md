# es安全认证

参考文章

1. [干货 | Elasticsearch 7.1免费安全功能全景认知](https://blog.csdn.net/laoyang360/article/details/90554761)
    - es 安全机制的演变历程
2. [<十三>ELK-学习笔记–elasticsearch-7.x使用xpack进行安全认证](http://www.eryajf.net/3500.html)
    - 单机与集群环境开启安全认证的实际操作示例.
    - ES中内置了几个管理其他集成组件的账号: apm_system, beats_system, elastic, kibana, logstash_system, remote_monitoring_user

es版本: 7.2.0

默认 es 是没有密码的, 无论是 curl, 还是 kibana, logstash, 都可以直接访问, 不用配置用户名密码.

要开启es的密码认证, 需要添加`xpack.security.enabled: true`(默认为`false`), 之后 es 配置 username/password 才有效.


```yaml
## 这条配置表示开启xpack认证机制
xpack.security.enabled: true 

```

当然, 之后 `curl`/`kibana`/`logstash` 也需要配置对应的用户名密码才行.

## 关于内置账号

但是, 大家都用同一个密码, 同样不安全. 毕竟, logstash 要部署在各个节点, 而 kibana 则是作为一个中心服务来运行的.

es 内置了一些集成组件的账号, 如: apm_system, beats_system, elastic, kibana, logstash_system, remote_monitoring_user. 但这些账号最初是没有密码的(不是默认的`changeme`不用想了...), 所以根本没办法使用与修改.

修改指定用户`elastic`的密码.

```
curl -u elastic:123456 -H 'Content-Type: application/json' es:9200/_xpack/security/user/elastic/_password -d '{"password": "654321"}'
```

返回`{}`即为成功.

## 关于密文密码



