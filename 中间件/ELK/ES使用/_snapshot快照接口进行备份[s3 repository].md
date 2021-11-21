# _snapshot快照接口进行备份[s3 repository]

参考文章

1. [Elasticsearch 快照和恢复](https://www.cnblogs.com/kgdxpr/p/9522634.html)
2. [S3 Repository Plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/7.5/repository-s3.html)

es: 7.5.1(不适用于5.x)

安装`repository-s3`插件后, 可以将es中的数据备份到指定OSS服务器上.

首先通过`_snapshot`创建一个仓库, 如下

```
PUT _snapshot/test-oss-repository
{
    "type" : "s3",
    "settings" : {
      "endpoint" : "http://xxx.xxx.xxx.xxx:80",
      "bucket" : "test-oss-bucket",
      "disable_chunked_encoding" : "true",
      "readonly" : "false",
      "compress" : "true",
      "client" : "test-oss-bucket",
      "base_path" : "test-oss-path"
    }
}
```

一般访问oss服务需要提供`access_key`与`secret_key`, 作为用户名和密码. es.v7中, 此类信息需要通过`elasticsearch-keystore`命令添加

```
elasticsearch-keystore add s3.client.zyj-1119-1_test-zjjpt-docker.secret_key
elasticsearch-keystore add s3.client.zyj-1119-1_test-zjjpt-docker.access_key
```

> key的内容要像密码一样交互式输入, 不需要显示出现在命令行中.

然后发起快照请求, 将指定索引备份到该oss仓库.

```
PUT _snapshot/test-oss-repository/snap01
```
