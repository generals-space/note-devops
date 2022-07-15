# fliebeat log level[debug]

参考文章

1. [Configure logging](https://www.elastic.co/guide/en/beats/filebeat/6.3/configuration-logging.html)
    - 官方文档

filebeat: 6.3.2

```yaml
logging.level: debug

filebeat.config.inputs:
  enable: true
  path: configs/*.yml
  reload.enabled: true
  reload.period: 10s
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
output.kafka:
  enabled: true
  hosts: ["kafka-server:9092"]
  topic: "xxx"
```
