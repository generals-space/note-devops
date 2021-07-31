# Java工程log4j2配置logstash收集日志

参考文章

1. [log4j使用SocketAppender推送日志到远程服务器(包含log4j如何升级到log4j2，并使用SocketAppender发送日志到LogStash)](https://blog.csdn.net/gotofind/article/details/79465998)
    - `log4j`工程需要logstash安装`logstash-input-log4j`作为输入插件才能使用, `log4j2`工程则不需要.
    - logstash即将停止维护log4j, 也不推荐使用log4j插件
2. [ELK入门02—Logstash+Log4j2+ES](https://segmentfault.com/a/1190000016192394)
    - `log4j2`与logstash的udp模式
3. [log4j2 + logstash](https://blog.csdn.net/weixin_34239592/article/details/89045689)
4. [Udp input plugin](https://www.elastic.co/guide/en/logstash/7.x/plugins-inputs-udp.html)
    - logstash官方文档

除了使用filebeat采集主机上指定路径的日志文件, Java工程还可以主机将日志发送到logstash, 然后由该logstash将日志集中发送到ES.

## log4j

```conf
## 注意: 这里的 logstash 就指定了下面的 log4j.appender.logstash, 
## 同理还应该有 log4j.appender.debug 和 log4j.appender.stdout.
log4j.rootLogger = debug,stdout,logstash

log4j.appender.logstash=org.apache.log4j.net.SocketAppender
## logstash主机IP与端口
log4j.appender.logstash.RemoteHost=127.0.0.1
log4j.appender.logstash.port=4560
log4j.appender.logstash.ReconnectionDelay=60000
log4j.appender.logstash.LocationInfo=true
```

对应的logstash集群中, 需要有如下配置

```conf
input {
    log4j {
        host => "0.0.0.0"
        mode => "server"
        port => 4560
    }
}
```

`logstash.yml`文件并不能定义logstash的监听端口, 只能通过`input`插件实现.

为了使用`log4j`功能, 则需要事先安装`logstash-input-log4j`插件.

## log4j2(通过udp方式发送到logstash)

```conf
## 这里的 remote 和上面的 log4j.appender.logstash 段一样, 名字随机.
## 每一个块都需要同样的模式进行定义
appender.remote.type = Socket
appender.remote.name = remote
## logstash IP与端口
appender.remote.host = 127.0.0.1
appender.remote.port = 4560
appender.remote.protocol = UDP
appender.remote.reconnectionDelayMillis = 10000
appender.remote.layout.type = PatternLayout
appender.remote.layout.pattern = xxxxxxxxxxxxx

```

然后logstash使用UDP模式进行监听

```conf
input {
    udp {
        ## udp 没有 mode 参数
        ## mode => "server"
        host => "0.0.0.0"
        port => 4560
    }
}
```

## 相应的output.elasticsearch配置

```conf
output {
    stdout { codec => rubydebug }
    elasticsearch {
        hosts => ["localhost:9200"]
        user => "elastic"
        password => "123456"
        index => "logstash-%{+YYYY.MM.dd}"
    }
}
```
