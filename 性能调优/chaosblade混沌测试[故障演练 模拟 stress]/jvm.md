参考文章

1. [我如何设置Java程序的进程名称？](https://cloud.tencent.com/developer/ask/61558)
    - jdk中提供了一个`jps`命令, 可以查看通过`java xxx`启动的进程名
    - 最开始我以为`blade prepare jvm`必须使用`--process`指定目标进程名, 但是java进程都是通过`java xxx`启动的, 根本拿不到进程名, 于是找到这篇文章.

jvm相关的模拟分为两步, 先`prepare`注入, 再`create`创建模拟场景.

```
blade prepare jvm --help
Attach a type agent to the jvm process for java framework experiment.

Usage:
  blade prepare jvm

Examples:
prepare jvm --process tomcat

Flags:
  -a, --async             whether to attach asynchronously, default is false
  -e, --endpoint string   the attach result reporting address. It takes effect only when the async value is true and the value is not empty
  -h, --help              help for jvm
  -j, --javaHome string   the java jdk home path
  -n, --nohup             used to internal async attach, no need to config
      --pid string        the target java process id
  -P, --port int          the port used for agent server
  -p, --process string    the java application process name (required)
  -u, --uid string        used to internal async attach, no need to config

```

一般直接使用`--pid`就可以了, `--process`虽然写的是`required`, 但是其实不需要.

不是所有`java`进程都支持`prepare`, 应该与jdk有关系.

比如 rocketmq-4.1.0, broker 的注入就很成功.

![](https://gitee.com/generals-space/gitimg/raw/master/4bdd207962767dc52e2e93cbe75bb61b.png)

但是对于 ES-5.5.0, 注入时就出了各种问题.

![](https://gitee.com/generals-space/gitimg/raw/master/af9ba9ccfad9d8552ea88340a18f4a4b.png)

最开始我以为是因为执行`blade`命令的用户和es的启动用户不同, 所以造成了这个问题, 于是切换用户执行.

![](https://gitee.com/generals-space/gitimg/raw/master/4763db722caa576098398c41fe73316b.png)

但还是不行.

查看该es节点的日志如下

![](https://gitee.com/generals-space/gitimg/raw/master/2533b09f7cb3e088105be93985f0128b.png)

估计是不行了.
