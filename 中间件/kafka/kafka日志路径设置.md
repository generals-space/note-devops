# kafka日志路径设置

参考文章

1. [Kafka_Kafka设置日志输出路径 LOG_DIR](https://blog.csdn.net/u010003835/article/details/53930930/)

在`config/server.properties`配置文件中, 存在一个`log.dirs`字段, 但是这个字段指定的是kafka的数据目录, 而非日志目录.

kakfa的日志默认会输出到与`bin`, `config`同级的`logs`目录下, 在`bin/kafka-run-class.sh`中, 有如下声明

```sh
# Log directory to use
if [ "x$LOG_DIR" = "x" ]; then
  LOG_DIR="$base_dir/logs"
fi
```

所以只要设置一个`LOG_DIR`环境变量即可.
