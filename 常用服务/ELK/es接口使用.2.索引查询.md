在ELK体系中, 一个索引就表示一组日志信息, logstash 把同类型的日志写入到 es, ta们拥有相同的关键字段, 比如日期, 用户名等, 存储在 es 中.

比如 logstash 的 pipeline 配置如下, 用以收集 nginx 的日志.

```conf
input {
    file {
       path => "/var/log/nginx/access_json.log"
       codec => json ## 由于nginx的日志配置为json格式, 所以这里的codec指定为json.
       start_position => "beginning"
       type => "nginx-log"
    }
}
output {
    if [type] == "nginx-log"{
        elasticsearch {
            ## 这里的 es-cluster 为 elasticsearch 的 service 名称
            hosts => "es-cluster:9200"
            user => "elastic"
            password => "123456"
            index => "nginx-log-%{+YYYY.MM.dd}"
        }
    }
}
```

那么会在 es 中创建按照`index`分割的索引记录.

![](https://gitee.com/generals-space/gitimg/raw/master/2F884ECB2A05DBBCDC96C4A39586A4ED.png)

当然, 之后可以在 kibana 中将`nginx-log-*`的数据合并进行查询, 如下

![](https://gitee.com/generals-space/gitimg/raw/master/3631D269FAD36530965FCC8968A53CAD.png)

我们要理解的, 就是"索引"的概念.

## 1. `/_cat/indices`

查看集群内**所有索引**信息, 包含各索引的名称(index), 状态, 信息数量及大小等信息.

```json
[
  {
    "health" : "green",
    "status" : "open",
    "index" : "nginx-log-2020.06.21",
    "uuid" : "R7xI_XCsTgiU1MwDMQkvqQ",
    "pri" : "1",
    "rep" : "1",
    "docs.count" : "21",
    "docs.deleted" : "0",
    "store.size" : "48.4kb",
    "pri.store.size" : "24.2kb"
  },
  // ...省略
]
```

```
$ curl -u elastic:changeme localhost:9200/_cat/indices
green open .monitoring-kibana-6-2020.11.03 45fvV3uEROWwL36Xzl0QXw 1 1   226  0 274.8kb 137.4kb
green open .triggered_watches              pTQ4Wmh6SHW_psDwUf7X3w 1 1     0  0  46.9kb  23.4kb
green open .watches                        Vp4K3lYHRxiNcmtI-4_4EA 1 1     4  0 126.8kb  63.4kb
green open .watcher-history-3-2020.11.02   Njh5tw2dSx65bDlagR3p_Q 1 1   646  0     1mb 559.3kb
```

在重启 es data 节点的时候, 集群可能由于恢复索引变成 yellow, 在这个过程中, 可以通过此接口查看各索引的状态.

## 2. `/索引名`

可以查看该索引下的字段信息. 

```
{
  "nginx-log-2020.06.21" : {
    "aliases" : { },
    "mappings" : {
      "properties" : {
        "@timestamp" : {
          "type" : "date"
        },
        "domain" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "host" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "path" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "ua" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        }
      }
    },
    "settings" : {
      "index" : {
        "creation_date" : "1592798943911",
        "number_of_shards" : "1",
        "number_of_replicas" : "1",
        "uuid" : "R7xI_XCsTgiU1MwDMQkvqQ",
        "version" : {
          "created" : "7020099"
        },
        "provided_name" : "nginx-log-2020.06.21"
      }
    }
  }
}
```

同级的还有

1. `/索引名/_mapping`
2. `/索引名/_settings`

