# filebeat+es[pipeline]配置示例

```
filebeat -c filebeat.yml
```

`filebeat.yml`的配置如下

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
  pipeline: '%{[log_topics]}'
```

`configs`目录下, 有如下配置文件.

```yml
- input_type: log 
  enabled: true 
  paths: 
    - /data/kafka/**/log/server.log 
  close_inactive: 2h 
  force_close_files: true 
  exclude_files: [".gz$"] 
  include_lines: ["^[0-9]"]
  fields: 
    log_topics: kafka_log 
  fields_under_root: true 
  ignore_older: 24h 
  close_inactive: 24h 
  force_close_files: true 
  max_bytes: 10240 
  recursive_glob.enabled: true 
  tail_files: true
```

`paths`字段下, 双星号`**`可以表示多个层级, 如可以匹配如下具体路径

1. /data/kafka/log/server.log 
2. /data/kafka/aaa/log/server.log 
3. /data/kafka/aaa/bbb/log/server.log 

`include_lines`可以过滤目标文件中的行, 只选择以数字开头的(一般是日期信息), 不符合的行将不予处理, 如下

```
08/02/2021 10:25:45 passing arg to libvncserver: -rfbauth
```

`fields`中, 为每行日志都添加上了`log_topics`字段, 由filebeat根据这个字段选择发送到ES的哪个pipeline进行处理.
