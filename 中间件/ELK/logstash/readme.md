# logstash

参考文章

1. [管道配置文件的结构](https://www.kancloud.cn/aiyinsi-tan/logstash/854012)

logstash的配置分为2部分, 一个是`logstash.yml`文件, 一个是`pipeline.conf`文件.

其中前者定义了要加载的`pipeline`文件路径以及命名定义, 后者则是要处理的数据的信息了, 包括input数据源, filter处理规则, output输出目标.

logstash的主要配置还是在后者身上.

input: 可以是本地文件(用于采集本地日志内容), kafka(可以指定kafka的IP与端口, topic);

filter: 可以对输入的每行数据进行处理, 包括添加, 删除自定义字段, 修改已知字段的值等功能, 也可以做简单的逻辑判断, 比较像一种简单的编程语言;

output: 可以是标准输出, 可以是本地文件(指定目标文件路径), 也可以是elasticsearch(指定IP, 端口, 用户名及密码, 以及索引名称);

## 示例

### 1. 

```conf
input {
    stdin {}
}
output {
    stdout {}
}
```

logstash启动完成后(前端启动, 不要用守护进程), 就在打印日志的终端中写内容然后回车, 就会输出响应.

### 2.

```
input {
    file {
        path => "/etc/os-release"
    }
}
output {
    stdout {
        codec => rubydebug
    }
}
```

读取一个文件的内容并打印到标准输出.
