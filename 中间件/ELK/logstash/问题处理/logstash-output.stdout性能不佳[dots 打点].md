# logstash-output.stdout性能不佳[dots 打点]

使用grafana对logstash进程进行监控, 按plugin分别统计性能耗时, 发现常规的`mute`, `ruby`的耗时只有毫秒级, 而`stdou`的插件耗时竟然高达10几秒...

将`stdout`修改成`dots`后, 性能立刻提升.

```
output {
    stdout {}
}
```

```
output {
    stdout {
        codec => dots
    }
}
```
