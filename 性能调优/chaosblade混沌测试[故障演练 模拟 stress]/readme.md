参考文章

1. [官方工程](https://github.com/chaosblade-io/chaosblade)

官方称谓是"混沌测试", how tm 高大上的名字...

```console
$ blade create --help
  cplus       C++ chaos experiments
  cpu         Cpu experiment
  disk        Disk experiment
  docker      Docker experiment
  druid       Experiment with the Druid
  dubbo       Experiment with the Dubbo
  file        File experiment
  http        http experiment
  jedis       jedis experiment
  jvm         Experiment with the JVM
  k8s         Kubernetes experiment
  mem         Mem experiment
  mongodb     MongoDB experiment
  mysql       mysql experiment
  network     Network experiment
  process     Process experiment
  psql        Postgrelsql experiment
  rabbitmq    rabbitmq experiment
  rocketmq    Rocketmq experiment,can make message send or pull delay and exception
  script      Script chaos experiment
  servlet     java servlet experiment
  tars        tars experiment
```

使用`blade create cpu --help`可以查看单项测试的可用参数.
