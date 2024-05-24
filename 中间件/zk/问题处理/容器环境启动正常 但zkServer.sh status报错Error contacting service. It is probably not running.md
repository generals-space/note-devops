# 容器环境启动正常 但zkServer.sh status报错Error contacting service. It is probably not running

参考文章

1. [zkServer.sh start启动正常 zkServer.sh status启动异常 解决办法](https://blog.csdn.net/wangming520liwei/article/details/81119721)
    - 呃...2181端口被占用还能启动成功?
2. [【已解决】zookeeper显示Error contacting service. It is probably not running等问题](https://www.iwangzhu.cn/article/8)
    - 扯, `server.X`中的`X`可以是从0开始的(虽然好像网上所有文章都是从1开始, 连官网也是).
3. [人工智能 安装zookeeper时候，可以查看进程启动，但是状态显示报错 Error contacting service. It is probably not running](https://www.dazhuanlan.com/fan_zhentao/topics/1504919)
4. [CentOS下ZooKeeper的安装教程（单机模式）](https://www.hangge.com/blog/cache/detail_2790.html)
    - 同参考文章2
5. [bin/zkServer.sh status fails when jmx_prometheus_javaagent added as agent #392](https://github.com/prometheus/jmx_exporter/issues/392)

zk: 3.4.9 (3节点)

kubernetes: 1.17.2

容器镜像使用 CentOS7 + zk安装包自行封装.

## 问题描述

zk的3个节点全部启动, 集群也建起来了, 正常对外提供服务. 但是执行`zkServer.sh status`查询节点状态异常, 如下

```log
$ ./bin/zkServer.sh status 
ZooKeeper JMX enabled by default 
Using config: /usr/zookeeper-3.4.9/bin/../conf/zoo.cfg 
Error contacting service. It is probably not running
```

使用`jps`可以看到zk进程

```
$ jps
26 QuorumPeerMain
120300 Jps
```

## 排查过程

### 

按照参考文章1中所说, 修改`bin/zkServer.sh`, 查看`status`子命令的详细过程.

```bash
STAT=`"$JAVA" "-Dzookeeper.log.dir=${ZOO_LOG_DIR}" "-Dzookeeper.root.logger=${ZOO_LOG4J_PROP}" \ -cp "$CLASSPATH" $JVMFLAGS org.apache.zookeeper.client.FourLetterWordMain \ $clientPortAddress $clientPort srvr 2> /dev/null \ | $GREP Mode`
```

将上述语句的`2> /dev/null`以及后面的管道过滤语句移除, 查看`srvr`指令的输出, 得到如下

```
Exception in thread "main" java.lang.reflect.InvocationTargetException
    at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
    at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    at java.lang.reflect.Method.invoke(Method.java:498)
    at sun.instrument.InstrumentationImpl.loadClassAndStartAgent(InstrumentationImpl.java:386)
    at sun.instrument.InstrumentationImpl.loadClassAndCallPremain(InstrumentationImpl.java:401)
Caused by: java.net.BindException: Address already in use
    at sun.nio.ch.Net.bind0(Native Method)
    at sun.nio.ch.Net.bind(Net.java:433)
    at sun.nio.ch.Net.bind(Net.java:425)
    at sun.nio.ch.ServerSocketChannelImpl.bind(ServerSocketChannelImpl.java:223)
    at sun.nio.ch.ServerSocketAdaptor.bind(ServerSocketAdaptor.java:74)
    at sun.net.httpserver.ServerImpl.<init>(ServerImpl.java:100)
    at sun.net.httpserver.HttpServerImpl.<init>(HttpServerImpl.java:50)
    at sun.net.httpserver.DefaultHttpServerProvider.createHttpServer(DefaultHttpServerProvider.java:35)
    at com.sun.net.httpserver.HttpServer.create(HttpServer.java:130)
    at io.prometheus.jmx.shaded.io.prometheus.client.exporter.HTTPServer.<init>(HTTPServer.java:179)
    at io.prometheus.jmx.shaded.io.prometheus.jmx.JavaAgent.premain(JavaAgent.java:31) ... 6 more 
FATAL ERROR in native method: processing of -javaagent failed
```

和参考文章1中说的一样, 都是`Address already in use`, 但是ta没说是哪个端口啊...🤔

而且zk都正常运行了, 2181/3888这种被占用不是很正常的事情嘛...

### 

下面就是碰运气的过程了, 按照参考文章2提到的`dataLogDir`目录没有成功创建, 或是`myid`路径不正确的问题...这些配置不正确能启动成功?

参考文章3提到了防火墙, 嗯...容器里根本没有防火墙. 另外`/etc/hosts`也没必要, `server.X`中的地址各节点是可以相互通信的(当然我也试了下, 不出所料🤔).

## 解决方法

最终的解决方法是参考文章5, 为了实现在容器环境下对zk容器的监控, 我们使用了`jmx_exporter`, 于是修改了`zkServer.sh`中的`JVMFLAGS`变量.

```bash
JVMFLAGS="$JVMFLAGS -javaagent:$JMX_DIR/jmx_prometheus_javaagent-0.15.0.jar=19105:$JMX_DIR/zookeeper.yaml"
```

将这一行注释掉, 再执行`zkServer.sh status`, 就可以了.

------

另外, 除了这个原因, 还有一个原因是, 我们的`zoo.cfg`配置不标准, 如下

```conf
clientPort:2181
server.0:zk-ha-test-busi-kafka-0.zk-ha-test-busi-kafka-svc.zjjpt-zk.svc.cs-hua.hpc:2888:3888
server.1:zk-ha-test-busi-kafka-1.zk-ha-test-busi-kafka-svc.zjjpt-zk.svc.cs-hua.hpc:2888:3888
server.2:zk-ha-test-busi-kafka-2.zk-ha-test-busi-kafka-svc.zjjpt-zk.svc.cs-hua.hpc:2888:3888
dataLogDir:/data/zk-ha-test-busi-kafka-0/log
dataDir:/data/zk-ha-test-busi-kafka-0
## ...省略
```

用冒号`:`代替了等号`=`, zk竟然可以正常运行😱.

这样导致在`zkServer.sh`中在执行`status`子命令时, 从`zoo.cfg`中解析`clientPort`变量会有问题.

```
clientPort=`$GREP "^[[:space:]]*clientPort[^[:alpha:]]" "$ZOOCFG" | sed -e 's/.*=//'`
```

后面的`sed`指令是按`=`进行切分的, 这样得到的结果为`clientPort:2181`, 是个非法数值.

修改`zoo.cfg`的格式后就可以了.
