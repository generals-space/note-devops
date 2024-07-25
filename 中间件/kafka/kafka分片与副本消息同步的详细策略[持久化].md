# kafka分片与副本消息同步的详细策略[持久化]

参考文章

1. [Kafka学习之路 （三）Kafka的高可用](https://www.cnblogs.com/qingyunzong/p/9004703.html)
    - Data Replication（副本策略）

## 1. 消息传递同步策略

1. Producer在发布消息到某个Partition时，先通过ZooKeeper找到该Partition的Leader，然后无论该Topic的Replication Factor为多少，Producer只将该消息发送到该Partition的Leader。
2. Leader会将该消息写入其本地Log。
3. 每个Follower都从Leader pull数据。Follower在收到该消息并写入其Log后，向Leader发送ACK。一旦Leader收到了ISR中的**所有Replica**的ACK，该消息就被认为已经commit了，Leader将增加HW并且向Producer发送ACK。

为了提高性能，每个Follower在接收到数据后就立马向Leader发送ACK，而非等到数据写入Log中。因此，对于已经commit的消息，Kafka只能保证它被存于多个Replica的内存中，而**不能保证它们被持久化到磁盘中**，也就不能完全保证异常发生后该条消息一定能被Consumer消费。

Consumer读消息也是从Leader读取，只有被commit过的消息才会暴露给Consumer。
