# es选主策略[选举 5.x]

参考文章

1. [Zen Discovery](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/modules-discovery-zen.html)
    - 官方文档
    - `discovery.zen.ping_timeout`默认为`3s`, 
2. [discovery.zen.ping_timeout 参数作用的疑惑和探究](https://elasticsearch.cn/question/4199)
    - `discovery.zen.ping_timeout`参数配置越大，选主的过程越长
    - 答主 kennywu76 非常给力👍🏻
3. [ES 的 Master 节点的选举流程源码分析](https://www.bowlbear.com/1506)

- ES版本: 5.5.0
- 集群规格: master * 3 + data * 3

## 1. 第1个含义-节点探测超时时间

按照参考文章1的说法, 在ping操作(节点发现机制, 即discovery)过程中, 会将配置好的master节点加入集群, 同时也会完成主master的选举. 这是一个后台且不断持续的行为, 保证master节点异常脱离后(比如重启, 断网), 还可以再加回来.

但有些master节点可能因为网络拥堵(或单纯就是网速慢)导致响应时间过长, 探测失败, 无法加入集群, 那么就需要调整一下这个超时时间配置`discovery.zen.ping_timeout`.

这个解释其实很好理解, 但是实际上在测试的时候, 发现这个配置带来了一些副作用🤨.

## 2. 第2个含义-选主耗时

有一个建立好的ES集群, 访问`/_cat/nodes`接口有如下输出

```log
192.168.34.33  3 12 7 1.10 2.60 2.54 mi - es-0119-01-master-2
192.168.34.36  4 51 5 0.63 0.72 0.87 mi - es-0119-01-master-0
192.168.34.20  7 59 5 0.43 1.08 1.45 di - es-0119-01-data-1
192.168.34.68  6 59 5 0.43 1.08 1.45 mi * es-0119-01-master-1
192.168.34.135 6 12 8 1.10 2.60 2.54 di - es-0119-01-data-2
192.168.34.66  9 51 5 0.63 0.72 0.87 di - es-0119-01-data-0
```

可以看到, 其中master-1是主Master节点, master-0, master-2是从Master节点.

手动重启master-1所在容器, 剩下的2个从Master会自动选出新的主Master, 组建成新的集群, 等到master-1重启完成, 再次加入集群, 就只能作为一个从Master了.

在master-1重启到完成的过程中, 查看master-2的日志, 有如下典型的输出.

```log
[2022-01-20T12:26:33,264][WARN ][o.e.c.NodeConnectionsService] [es-0119-01-master-2] failed to connect to node {es-0119-01-master-1}{EErKdnU4R5eTM8kcdIe9zw}{QGX9mVsiSWODEc9n18pYuw}{192.168.34.68}{192.168.34.68:9311}{ml.enabled=true} (tried [1] times)
org.elasticsearch.transport.ConnectTransportException: [es-0119-01-master-1][192.168.34.68:9311] connect_timeout[30s]
        at java.lang.Thread.run(Thread.java:748) [?:1.8.0_232]
Caused by: io.netty.channel.AbstractChannel$AnnotatedConnectException: Connection refused: 192.168.34.68/192.168.34.68:9311
        ... 1 more
Caused by: java.net.ConnectException: Connection refused
        ... 1 more
## 注意以下2行 !!!
[2022-01-20T12:26:33,938][DEBUG][o.e.a.a.c.h.TransportClusterHealthAction] [es-0119-01-master-2] no known master node, scheduling a retry
[2022-01-20T12:27:03,335][INFO ][o.e.c.s.ClusterService   ] [es-0119-01-master-2] new_master {es-0119-01-master-2}{q3v-IFW4RmuzDZdOShwcqQ}{-ULWFzXFTgGpl9XMOHUpiA}{192.168.34.33}{192.168.34.33:9311}{ml.enabled=true}, reason: zen-disco-elected-as-master ([3] nodes joined)[{es-0119-01-data-2}{0JDHBbBPSNeQIhH1KlhXaQ}{nRQxh-q3QqCu5in4l9IMsw}{192.168.34.135}{192.168.34.135:9311}{ml.enabled=true}, {es-0119-01-master-0}{sB5XM6iUSaeykwDlRPcTGg}{v9tBNhu-TfmZX8Sd-g2j3A}{192.168.34.36}{192.168.34.36:9311}{ml.enabled=true}, {es-0119-01-data-1}{jOYjggouRYKS2iDIiMrmdQ}{00K08cxtQ_K82OHmpwbDXQ}{192.168.34.20}{192.168.34.20:9311}{ml.enabled=true}]
[2022-01-20T12:27:03,431][INFO ][o.e.c.s.ClusterService   ] [es-0119-01-master-2] removed {{es-0119-01-master-1}{EErKdnU4R5eTM8kcdIe9zw}{QGX9mVsiSWODEc9n18pYuw}{192.168.34.68}{192.168.34.68:9311}{ml.enabled=true},}, reason: zen-disco-node-failed({es-0119-01-master-1}{EErKdnU4R5eTM8kcdIe9zw}{QGX9mVsiSWODEc9n18pYuw}{192.168.34.68}{192.168.34.68:9311}{ml.enabled=true}), reason(transport disconnected)[{es-0119-01-master-1}{EErKdnU4R5eTM8kcdIe9zw}{QGX9mVsiSWODEc9n18pYuw}{192.168.34.68}{192.168.34.68:9311}{ml.enabled=true} transport disconnected, {es-0119-01-master-1}{EErKdnU4R5eTM8kcdIe9zw}{QGX9mVsiSWODEc9n18pYuw}{192.168.34.68}{192.168.34.68:9311}{ml.enabled=true} transport disconnected]
[2022-01-20T12:27:39,268][INFO ][o.e.c.s.ClusterService   ] [es-0119-01-master-2] added {{es-0119-01-master-1}{EErKdnU4R5eTM8kcdIe9zw}{8kp5RQNeTnmBahEKyFwuPw}{192.168.34.68}{192.168.34.68:9311}{ml.enabled=true},}, reason: zen-disco-node-join[{es-0119-01-master-1}{EErKdnU4R5eTM8kcdIe9zw}{8kp5RQNeTnmBahEKyFwuPw}{192.168.34.68}{192.168.34.68:9311}{ml.enabled=true}]
```

在"no known master node"与"new_master"之间, 存在一定的时间间隔("12:26:33 - 12:27:03"), 这个时间与`discovery.zen.ping_timeout`配置的时间相符(实测3s, 10s, 30s, 可以确认此结论).

就是说, `discovery.zen.ping_timeout`配置会影响整个选主过程的耗时. 

注意, 只影响选主耗时, 不影响master节点加入集群的耗时.

并且, 这个配置并不表示对已加入集群的节点异常状态(比如因为负载过重, 或是网络抖动脱离集群)检测的超时, 那是由另外一个"discovery.zen.fd.ping_timeout"控制的.

## 3. 理论依据

参考文章2中, 高票答案的解释十分详细.

整个选主流程中, 会连续发送3次ping测试, 如下(这里借鉴了题主贴的代码)

1. 发送第一轮ping
2. shedule第二轮ping，间隔为1/2 timeout时间
3. schedule第三轮 ping，间隔为 1/2 timeout时间。 
4. 第三轮sendpings传递了waitTime参数，其值也是1/2 timeout时间，用于设置countdown latch await时长。如果对每个node的ping测试很快顺利完成，latch countdown应该也是瞬间的，这里几乎没有什么耗时。
5. 通知listener结果，结束选主过程。

> 连续ping 3次, 是为了保证参选的master都是合格的吧? 避免某些不网络稳定的节点成为了主Master, 结果又脱离集群了, 影响使用.

假设discovery.zen.ping_timeout是默认的3s， 并且所有结点都正常工作，立即响应ping请求。那么上述步骤耗时大致应该为:

1. ~ 0(约等于0)
2. 1.5s
3. 1.5s 
4. ~ 0
5. ~ 0

即大约3s完成，也就是选主过程基本和timeout时长一致。 

再次假设, 只有第一轮ping检测timeout，后面两轮顺利，则这个过程耗时应该大致为:

1. ~ 3s (timed out)
2. 1.5s
3. 1.5s
4. ~ 0 
5. ~ 0

总共是~~6s~~ 4.5s. 

**为什么是4.5s?**

因为3轮ping是在独立线程中执行的, 第1个线程delay 0秒(立即执行), 第2个线程delay 1.5s执行, 第3个线程delay 3s执行. 第1个线程ping超时并不会影响后续线程的ping操作, 所以最多是 (3/2) * 3 = 4.5s
