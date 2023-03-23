参考文章

1. [Logstash-配置](https://www.jianshu.com/p/f48f48ab3d59)

```yaml
- pipeline.id: es
  path.config: "/usr/share/logstash/config/pipelines/es.conf"
- pipeline.id: redis
  path.config: "/usr/share/logstash/config/pipelines/redis.conf"
- pipeline.id: mq
  path.config: "/usr/share/logstash/config/pipelines/mq.conf"
```
