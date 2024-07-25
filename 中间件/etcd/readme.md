参考文章

1. [etcd键值存储系统的介绍和使用](https://blog.csdn.net/u010424605/article/details/44592533)
    - etcd restful接口的使用示例(curl)
2. [CoreOS 实战：剖析 etcd](https://www.infoq.cn/article/coreos-analyse-etcd/)
3. [K8s 核心组件讲解——etcd](https://www.nowcoder.com/discuss/490507897575600128)
    - 基于 Raft 共识算法，实现分布式系统内部数据存储、服务调用的一致性和高可用性
    - watch 机制支持 watch 某个固定的 key，也支持一个范围 (前缀机制)
    - Revision 版本机制
    - Lease 租约机制
    - etcd 经常用于服务注册与发现的场景，此外还有键值对存储、消息发布与订阅、分布式锁等场景
