# logstash-打印可用字段[metadata message host mutate]

参考文章

1. [How to access available fields of @metadata in logstash](https://stackoverflow.com/questions/41953160/how-to-access-available-fields-of-metadata-in-logstash)

logstash 中每个事件都会包含"message"字段, 但很多时候我们还需要引用一些额外的字段信息(如"%{host}", "%{[@metadata][type]}"), 尤其是不同input(stdin, file, kafka)得到的事件字段信息并不相同, 可能需要打印一下未做任何处理的"原生"消息, 可以使用如下配置

```conf
output {
    stdout {
        codec => rubydebug {
        metadata => true
    }
}
```

常用的变量有"%{host}", "%{message}", "%{@timestamp}"等
