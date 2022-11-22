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

```conf
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
