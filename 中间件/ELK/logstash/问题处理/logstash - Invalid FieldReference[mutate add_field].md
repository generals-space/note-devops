# logstash - Invalid FieldReference[mutate add_field]

参考文章

1. [Invalid FieldReference](https://discuss.elastic.co/t/invalid-fieldreference/178721)

logstash 7.5.1

原来的 pipeline 如下

```conf
filter {
    ## 字符串处理
    mutate {
        ## 按 || 对 message 进行分割, 得到一个数组
        split => [ "message", "||" ]
        add_field => {
            "logType" => "%{message[0]}"
        }
    }
}
```

处理 input 消息时报错(不影响 logstash 运行)

```
{"message":["runlog "," center-log-collect "," center-log-collect-0 "," 2022-06-06T10:53:34,595 "," WARN  "," logstash.filters.mutate   "," Exception caught while applying mutate filter {:exception=>\"Invalid FieldReference: `message[0]`\"}\n"],"host":"127.0.0.1","tags":["_grokparsefailure","_mutate_error"],"@version":"1","@timestamp":"2022-06-06T02:53:34.596Z"}
```

按照参考文章1中的解决方案, `add_filed`对`message`字段的引用城改成如下

```
filter {
    ## 字符串处理
    mutate {
        ## 按 || 对 message 进行分割, 得到一个数组
        split => [ "message", "||" ]
        add_field => {
            "logType" => "%{[message][0]}"
        }
    }
}
```

解决!
