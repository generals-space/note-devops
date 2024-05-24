# es安全认证.1.单机

参考文章

1. [干货 | Elasticsearch 7.1免费安全功能全景认知](https://blog.csdn.net/laoyang360/article/details/90554761)
    - es 安全机制的演变历程
2. [<十三>ELK-学习笔记–elasticsearch-7.x使用xpack进行安全认证](http://www.eryajf.net/3500.html)
    - 单机与集群环境开启安全认证的实际操作示例.
    - ES中内置了几个管理其他集成组件的账号: apm_system, beats_system, elastic, kibana, logstash_system, remote_monitoring_user
    - kibana密文密码

es版本: 7.2.0

默认 es 是没有密码的, 无论是 curl, 还是 kibana, logstash, 都可以直接访问, 不用配置用户名密码.

要开启es的密码认证, 需要添加`xpack.security.enabled: true`(默认为`false`), 之后 es 配置 username/password 才有效.

当然, 之后 `curl`/`kibana`/`logstash` 也需要配置对应的用户名密码才行.

## 使用`curl`设置指定用户的密码

修改指定用户`elastic`的密码.

```
curl -u elastic:123456 -H 'Content-Type: application/json' es:9200/_xpack/security/user/elastic/_password -d '{"password": "654321"}'
```

返回`{}`即为成功.

## 关于内置账号

大家都用同一个密码, 同样不安全. 毕竟, logstash 要部署在各个节点, 而 kibana 则是作为一个中心服务来运行的, 职责不同, 面向的用户也不同.

es 内置了一些集成组件的账号, 如: apm_system, beats_system, elastic, kibana, logstash_system, remote_monitoring_user. 

这些账号最初存在叫作"bootstrap password"(不是默认的`changeme`或是空, 不用想了...), 也没有在配置文件配置的方法, 只能通过`ELASTIC_USERNAME`和`ELASTIC_PASSWORD`环境变量来设置`elastic`用户的密码. 

那么我们可以看出来, **`elastic`应该是es的主账号, 其他的`kibana`, `logstash_system`什么的, 都是给其他插件用的子账号**.

我们可以以`elastic`这个"超级"用户的身份修改其他用户的密码.

```
curl -u elastic:123456 -H 'Content-Type: application/json' es:9200/_xpack/security/user/kibana/_password -d '{"password": "123456"}'
```

如果尝试修改一个不存在的用户的密码, 就会报错.

```log
$ curl -u elastic:123456 -H 'Content-Type: application/json' es:9200/_xpack/security/user/xxxxxx/_password -d '{"password": "123456"}'
{"error":{"root_cause":[{"type":"validation_exception","reason":"Validation Failed: 1: user must exist in order to change password;"}],"type":"validation_exception","reason":"
Validation Failed: 1: user must exist in order to change password;"},"status":400}
```

## `elasticsearch-setup-passwords interactive`

这个工具可以设置es内置的所有账号的密码, ta会读取`config`目录下(ta本身在`bin`目录)的`elasticsearch.yml`得到本机es实例地址.

但是ta有个前提, **不要在配置文件或是环境变量中设置`elastic`的密码**.

es在 setup 初期, 所有的内置账号都有一个"bootstrap password", 但es并不希望用户修改ta. 而是在集群setup完成后, 执行这个命令来修改.

如果我通过环境变量修改了`elastic`的密码, 那么在调用这个工具的时候会得到如下报错.

```log
$ ./elasticsearch-setup-passwords interactive

Failed to authenticate user 'elastic' against http://10.254.1.54:9200/_security/_authenticate?pretty
Possible causes include:
 * The password for the 'elastic' user has already been changed on this cluster
 * Your elasticsearch node is running against a different keystore
   This tool used the keystore at /usr/share/elasticsearch/config/elasticsearch.keystore

ERROR: Failed to verify bootstrap password
```

那么我们就只能使用`curl`, 通过`/_xpack/security`接口为每个用户单独设置密码了.
