# gork插件-解析nginx.1.简单示例

参考文章

1. [21.4. logstash 配置项](http://www.netkiller.cn/monitoring/elk/logstash.html)
    - 各种类型日志的捕获示例, stdin, redis, nginx, mysql 等.
2. [logstash 官方文档 配置文件书写格式](https://www.elastic.co/guide/en/logstash/current/plugins-outputs-elasticsearch.html#plugins-outputs-elasticsearch-options)
    - `output.elasticsearch.hosts`数组的书写格式
3. [ELK 手册 - 8.1、grok正则过滤器配置](https://anbc.gitbooks.io/elk-handbook/content/81grokzheng_ze_guo_lv_qi_pei_zhi.html)


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
