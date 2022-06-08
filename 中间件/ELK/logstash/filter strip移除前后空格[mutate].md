# filter strip移除前后空格[mutate]

参考文章

1. [Remove trailing white space in logstash filter](https://discuss.elastic.co/t/remove-trailing-white-space-in-logstash-filter/110819)
2. [Mutate filter plugin](https://www.elastic.co/guide/en/logstash/7.5/plugins-filters-mutate.html#plugins-filters-mutate-strip)
    - 官方文档

按照参考文章1和2, strip 是 mutate 的一个子插件, 但是下面的规则却不能生效.

```conf
filter {
    mutate {
        ## 按 || 对 message 进行分割, 得到一个数组
        split => [ "message", "||" ]
        add_field => {
            ## _type 是 es 内置变量, 只能在 es 管道中设置, 在 logstash 设置后, 写入到 es 时会报错.
            ## "_type" => "%{[message][0]}"
            "logType" => "%{[message][0]}"
            "clusterName" => "%{[message][1]}"
            "instanceName" => "%{[message][2]}"
            "logTime" => "%{[message][3]}"
            "level" => "%{[message][4]}"
            "logContent" => "[%{[message][5]}] %{[message][6]}"
        }
        strip => [
            ## "_type", 
            "logType", "clusterName", "instanceName", "logTime", "level", "logContent"
        ]
        remove_field => ["message"]
    }
}
```

`logType`等字段内容前后的空格都没被去掉.

找了半天没找到解决方法, 后面尝试把`strip`从`add_filed`后面挪出来, 重新写了一个`mutate`块.

```conf
filter {
    mutate {
        ## 按 || 对 message 进行分割, 得到一个数组
        split => [ "message", "||" ]
        add_field => {
            ## _type 是 es 内置变量, 只能在 es 管道中设置, 在 logstash 设置后, 写入到 es 时会报错.
            ## "_type" => "%{[message][0]}"
            "logType" => "%{[message][0]}"
            "clusterName" => "%{[message][1]}"
            "instanceName" => "%{[message][2]}"
            "logTime" => "%{[message][3]}"
            "level" => "%{[message][4]}"
            "logContent" => "[%{[message][5]}] %{[message][6]}"
        }
        ## 紧接着在 add_field 后面使用 strip 不生效.
        ## strip => [
        ##     "_type", "logType", "clusterName", "instanceName", "logTime", "level", "logContent"
        ## ]
        remove_field => ["message"]
    }
    mutate {
        strip => [
            "logType", "clusterName", "instanceName", "logTime", "level", "logContent"
        ]
    }
}
```

这下可以了.
