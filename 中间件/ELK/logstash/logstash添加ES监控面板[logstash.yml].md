7.x

```yaml
    xpack.monitoring.enabled: true
    xpack.monitoring.elasticsearch.hosts: ["test-master-0.test-master.zjjpt-es.svc.cs-dev2.hpc:9211", "test-master-1.test-master.zjjpt-es.svc.cs-dev2.hpc:9211", "test-master-2.test-master.zjjpt-es.svc.cs-dev2.hpc:9211"]
    xpack.monitoring.elasticsearch.username: "elastic"
    xpack.monitoring.elasticsearch.password: "changeme"
```

5.x(注意: 需要额外安装x-pack插件, ES也是)

```yaml
    xpack.monitoring.enabled: true
    xpack.monitoring.elasticsearch.url: ["test-master-0.test-master.zjjpt-es.svc.cs-dev.hpc:9211", "test-master-1.test-master.zjjpt-es.svc.cs-dev.hpc:9211", "test-master-2.test-master.zjjpt-es.svc.cs-dev.hpc:9211"]
    xpack.monitoring.elasticsearch.username: "elastic"
    xpack.monitoring.elasticsearch.password: "changeme"
```
