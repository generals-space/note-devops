参考文章

1. [filebeat日志收集到elasticsearch](https://www.cnblogs.com/bird2048/p/17405977.html)
2. [Load the Elasticsearch index template](https://www.elastic.co/guide/en/beats/filebeat/6.3/configuration-template.html)

```yml
filebeat.config.inputs: 
  enable: true 
  path: configs/*.yml 
  reload.enabled: true 
  reload.period: 10s 
filebeat.config.modules: 
  path: ${path.config}/modules.d/*.yml 
  reload.enabled: false 
output.elasticsearch: ## 这里没有 filebeat. 前缀
  enabled: true 
  hosts: ["127.0.0.1:9200"] 
  username: "elastic" 
  password: "123456" 
  index: "kafka-log-%{+yyyy-MM-dd}"
  ## index: "%{[log_topics]}-%{+yyyy-MM-dd}"
setup.template.name: "kafka-log"
setup.template.pattern: "kafka-log*"
```

filebeat 会按`index`字段指定的格式创建索引, 但是创建索引的功能是由 es 提供的, 而该功能其实依赖的是 es 的 template 模板...

所有名称符合"kafka-log*"格式的索引, 都归该 tempalte 管理, 默认该 template 生成的索引, 分片为 5, 副本为 1. 如需修改, 可以按照如下格式

```yaml
setup.template.settings:
  index.number_of_shards: 3
  index.number_of_replicas: 1
```

