# logstash log4j输出[stdout java_stdout http]

参考文章

1. [Logstash Input和output的http配置](https://www.jianshu.com/p/c1d0795a12aa)

## 问题描述

logstash是java编写的服务, 使用log4j组件进行日志输出. 在实际使用场景中, 需要使用 remote 方式将日志发送到远程收集服务, 但是不是所有的日志都会发送, `stdout`打印出的日志信息是不会被发送的.

```conf
output {
    stdout {}
}
```

logstash启动后, 日志如下

```
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
Thread.exclusive is deprecated, use Thread::Mutex
Sending Logstash logs to /usr/share/logstash/logs which is now configured via log4j2.properties
[2022-02-10T18:07:08,983][INFO ][logstash.setting.writabledirectory] Creating directory {:setting=>"path.queue", :path=>"/usr/share/logstash/data/queue"}
[2022-02-10T18:07:09,156][INFO ][logstash.setting.writabledirectory] Creating directory {:setting=>"path.dead_letter_queue", :path=>"/usr/share/logstash/data/dead_letter_queue"}
[2022-02-10T18:07:10,094][WARN ][logstash.config.source.multilocal] Ignoring the 'pipelines.yml' file because modules or command line options are specified
[2022-02-10T18:07:10,159][INFO ][logstash.runner          ] Starting Logstash {"logstash.version"=>"7.5.1"}
[2022-02-10T18:07:10,191][INFO ][logstash.agent           ] No persistent UUID file found. Generating new UUID {:uuid=>"59a0f656-6ec8-4e4a-8af2-43999c82ecf8", :path=>"/usr/share/logstash/data/uuid"}
[2022-02-10T18:07:14,758][INFO ][org.reflections.Reflections] Reflections took 109 ms to scan 1 urls, producing 20 keys and 40 values
[2022-02-10T18:07:18,511][WARN ][org.logstash.instrument.metrics.gauge.LazyDelegatingGauge] A gauge metric of an unknown type (org.jruby.RubyArray) has been create for key: cluster_uuids. This may result in invalid serialization.  It is recommended to log an issue to the responsible developer/development team.
[2022-02-10T18:07:18,551][INFO ][logstash.javapipeline    ] Starting pipeline {:pipeline_id=>"main", "pipeline.workers"=>1, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>50, "pipeline.max_inflight"=>125, "pipeline.sources"=>["/usr/share/logstash/pipeline.config"], :thread=>"#<Thread:0x1294dc19 run>"}
[2022-02-10T18:07:20,052][INFO ][logstash.inputs.file     ] No sincedb_path set, generating one based on the "path" setting {:sincedb_path=>"/usr/share/logstash/data/plugins/inputs/file/.sincedb_a3d78292c8e005e666b7829c8f77277c", :path=>["/etc/os-release"]}
[2022-02-10T18:07:20,166][INFO ][logstash.javapipeline    ] Pipeline started {"pipeline.id"=>"main"}
[2022-02-10T18:07:20,559][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}
[2022-02-10T18:07:20,566][INFO ][filewatch.observingtail  ] START, creating Discoverer, Watch with file and sincedb collections
[2022-02-10T18:07:22,549][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
{
          "host" => "oss-test02-0.oss-test02-svc.zjjpt-logstash.svc.cs-dev2.hpc",
       "message" => "yes",
      "@version" => "1",
    "@timestamp" => 2022-02-10T18:07:22.751Z
}
```

可以看到, 由 log4j 打印出的内容, 都是遵循"[时间戳] [日志级别] [日志所属类] [日志正文]"这一格式的, 而下面包含"message"部分的日志, 则是直接打印到了标准输出, 所以这部分并不会被log4j组件发送到远程收集服务.

由于测试过程中, 需要有大量日志对远程收集服务进行压测, 必需要将这些日志由 log4j 输出出来.

本来在官方插件中, 还有一个`java_stdout`, 以为找到了希望, 结果和`stdout`没什么区别...

没办法, 最后找到了`http`插件, 向一个不存在的地址进行输出, 这会出现报错, 不过报错的日志量也不错了, 满足目前的需求(如果使用`es`插件, 错误重试间隔5s, 还是太慢).

```conf
output {
    http {
       http_method => "get"
       url => "http://127.0.0.1/xxx"
       message => "%{message}"
       request_timeout => 5
    }
}
```

报错日志可能包含如下格式内容

```
[HTTP Output Failure] Could not fetch URL {:url=>\"http://127.0.0.1/xxx\", :method=>:get, :body=>\"\", :message=>\"\"}
```

> 注意: input 至少需要输入一条消息才能触发.

