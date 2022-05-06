# 安装X-Pack插件之后Logstash无法正常启动[es elasticsearch]

参考文章

1. [安装X-Pack插件之后Logstash无法连接Elasticsearch](https://www.jianshu.com/p/cf21af48c8e2)

启动logstash时发现日志中一直在报错, 如下

```
[2022-04-27T17:06:25,500][INFO ][logstash.outputs.elasticsearch] Running health check to see if an Elasticsearch connection is working {:healthcheck_url=>http://logstash_system:xxxxxx@localhost:9200/, :path=>"/"}
[2022-04-27T17:06:25,503][WARN ][logstash.outputs.elasticsearch] Attempted to resurrect connection to dead ES instance, but got an error. {:url=>#<Java::JavaNet::URI:0x2ccd6b21>, :error_type=>LogStash::Outputs::ElasticSearch::HttpClient::Pool::HostUnreachableError, :error=>"Elasticsearch Unreachable: [http://logstash_system:xxxxxx@localhost:9200/][Manticore::SocketException] Connection refused (Connection refused)"}
[2022-04-27T17:06:30,504][INFO ][logstash.outputs.elasticsearch] Running health check to see if an Elasticsearch connection is working {:healthcheck_url=>http://logstash_system:xxxxxx@localhost:9200/, :path=>"/"}
```

错误信息显示, 连接es一直失败. 但问题是管道配置文件里根本没有写es啊...

```conf
input {
  file {
    path => "/etc/os-release"
  }
}
output{
  stdout {}
  file {
    path => "/tmp/logstash.log"
  }
}
```

而且此时管道工作是正常的, 向"/etc/os-release"文件中追加信息, 日志中是会有结果输出的.

```
echo good >> /etc/os-release
```

```
{"path":"/tmp/logstash.log","@timestamp":"2022-04-27T09:05:41.362Z","@version":"1","host":"hua-dlzx1-i1109-gyt","message":"good"}
```

根据参考文章3, 是因为logstash安装了x-pack插件, 所以在config/logstash.yml文件中一定要指定es的地址, 不然就会默认去找"localhost:9200", 才会引发这个错误. 如果用不到es, 那就把x-pack插件卸载掉.
