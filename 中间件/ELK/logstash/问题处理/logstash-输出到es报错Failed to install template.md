# logstash-输出到es报错Failed to install template

参考文章

1. [Logstash / Elasticsearch: “Failed to install template” / “ Got response code '400' ”](https://stackoverflow.com/questions/63862142/logstash-elasticsearch-failed-to-install-template-got-response-code-40)
2. [[ERROR][logstash.outputs.elasticsearch] Failed to install template. {:message=>”Got response code ‘400’ contacting Elasticsearch at URL ‘http://localhost:9200/_template/jose_prueba_v14’”](https://discuss.elastic.co/t/error-logstash-outputs-elasticsearch-failed-to-install-template-message-got-response-code-400-contacting-elasticsearch-at-url-http-localhost-9200-template-jose-prueba-v14/252582)

input和output比较常规

```conf
input {
    kafka {
        bootstrap_servers => "kafka:9092"
        topics => ["nginx"]
        codec => "json"
    }
}
output {
    elasticsearch {
        hosts => "elasticsearch:9200"
        user => "elastic"
        password => "123456"
        index => "nginx-log-%{+YYYY.MM.dd}"
    }
}

```

很有可能是`logstash`和`elasticsearch`的版本不匹配, 出现上述问题时, 我的logstash版本为5.5.0, 而es版本为7.5.1, 将logstash换成7.5.1后解决.
