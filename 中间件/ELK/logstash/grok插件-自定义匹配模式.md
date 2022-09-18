# grok插件-自定义匹配模式

参考文章

1. [logstash grok插件语法介绍](https://blog.csdn.net/qq_34021712/article/details/79746413)
    - 自定义模式`Oniguruma`语法与`pattern_definitions`, `patterns_dir`选项

参考文章1中提到了"更多时候logstash grok没办法提供你所需要的匹配类型，这个时候我们可以使用自定义", ta给出了方法, 但是没有给出具体示例, 这里我们来验证一下.

对于如下nginx日志

```
172.19.0.1 - - [13/Oct/2020:10:55:05 +0000] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36 Edg/85.0.564.44"
```

我们之前使用如下`grok`规则

```conf
filter {
    grok {
        match => { 
            "message" => "%{IP:client} - - \[%{HTTPDATE:timestamp}\] \"%{WORD:method} %{URIPATHPARAM:uri} HTTP/%{NUMBER:httpversion}\" %{NUMBER:status} %{NUMBER:bytes} \"-\" \"%{GREEDYDATA:agent}\"" 
        }
    }
}
```

下面我们使用自定义的模式代替`IP`模式.

## `Oniguruma`语法

语法如下

```
(?<field_name>the pattern here)
```

自定义IP模式如下

```
(?<myclient>[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})
```

`grok`规则如下

```conf
filter {
    grok {
        match => { 
            "message" => "(?<myclient>[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) - - \[%{HTTPDATE:timestamp}\] \"%{WORD:method} %{URIPATHPARAM:uri} HTTP/%{NUMBER:httpversion}\" %{NUMBER:status} %{NUMBER:bytes} \"-\" \"%{GREEDYDATA:agent}\"" 
        }
    }
}
```

> 自定义模式中前后的小括号是必需的, 否则`logstash`在解析日志时会报异常并退出.

## `pattern_definitions`自定义模式

使用`pattern_definitions`将自定义的模式放在`grok`块, 比直接放在`match`块中内联要简洁不少.

```conf
filter {
    grok {
        pattern_definitions => {
            "MYIP" => "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
        }
        match => { 
            "message" => "%{MYIP:client} - - \[%{HTTPDATE:timestamp}\] \"%{WORD:method} %{URIPATHPARAM:uri} HTTP/%{NUMBER:httpversion}\" %{NUMBER:status} %{NUMBER:bytes} \"-\" \"%{GREEDYDATA:agent}\"" 
        }
    }
}
```

## `patterns_dir`自定义模式

如果自定义模式很多, 那么放在`pattern_definitions`中会显得很杂乱, 我们可以创建一个专门存储正则模式的文件, 用`patterns_dir`指定ta的路径, 依然是从`match`中直接使用.

如下, 写入`/usr/share/logstash/grok/patterns`文件

```
MYIP [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}
```

`filter`的内容如下

```conf
filter {
    grok {
        patterns_dir => ["/usr/share/logstash/grok/patterns"]
        match => { 
            "message" => "%{MYIP:client} - - \[%{HTTPDATE:timestamp}\] \"%{WORD:method} %{URIPATHPARAM:uri} HTTP/%{NUMBER:httpversion}\" %{NUMBER:status} %{NUMBER:bytes} \"-\" \"%{GREEDYDATA:agent}\"" 
        }
    }
}
```

需要注意的是, 参考文章1中的示例中, 声明了`patterns_dir => ["./patterns"]`, 但是管道配置文件与正则模式文件不能放在同一目录, 否则logstash在启动时可能报如下错误

```
[2020-10-14T06:17:47,643][ERROR][logstash.agent           ] Failed to execute action {:action=>LogStash::PipelineAction::Create/pipeline_id:main, :exception=>"LogStash::ConfigurationError", :message=>"Expected one of #, input, filter, output at line 25, column 1 (byte 611) after ", :backtrace=>["/usr/share/logstash/logstash-core/lib/logstash/compiler.rb:41:in `compile_imperative'", "/usr/share/logstash/logstash-core/lib/logstash/compiler.rb:49:in `compile_graph'", "/usr/share/logstash/logstash-core/lib/logstash/compiler.rb:11:in `block in compile_sources'", "org/jruby/RubyArray.java:2577:in `map'", "/usr/share/logstash/logstash-core/lib/logstash/compiler.rb:10:in `compile_sources'", "org/logstash/execution/AbstractPipelineExt.java:151:in `initialize'", "org/logstash/execution/JavaBasePipelineExt.java:47:in `initialize'", "/usr/share/logstash/logstash-core/lib/logstash/java_pipeline.rb:24:in `initialize'", "/usr/share/logstash/logstash-core/lib/logstash/pipeline_action/create.rb:36:in `execute'", "/usr/share/logstash/logstash-core/lib/logstash/agent.rb:325:in `block in converge_state'"]}
[2020-10-14T06:17:48,087][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
[2020-10-14T06:17:53,013][INFO ][logstash.runner          ] Logstash shut down.
```

管道配置需要以`#`, `input`, `filter`或`output`作为行首, 正则模式的内容是不合法的.

所以最好指定绝对路径.
