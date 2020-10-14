参考文章

1. [21.4. logstash 配置项](http://www.netkiller.cn/monitoring/elk/logstash.html)
    - 各种类型日志的捕获示例, stdin, redis, nginx, mysql 等.

最简示例

```
172.19.0.1 - - [13/Oct/2020:10:55:05 +0000] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36 Edg/85.0.564.44"
```

```conf
input {
    file {
       path => "/var/log/nginx/access_json.log"
       start_position => "beginning"
       type => "nginx-log"
    }
}
filter {
    grok {
        match => { 
            "message" => "%{IP:client} - - \[%{HTTPDATE:timestamp}\] \"%{WORD:method} %{URIPATHPARAM:uri} HTTP/%{NUMBER:httpversion}\" %{NUMBER:status} %{NUMBER:bytes} \"-\" \"%{GREEDYDATA:agent}\"" 
        }
    }
}
output {
    if [type] == "nginx-log"{
        elasticsearch {
            hosts => "esc-master-0:9200"
            index => "nginx-log-%{+YYYY.MM.dd}"
        }
    }
}

```
