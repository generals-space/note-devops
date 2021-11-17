参考文章

1. [LINUX: 在不重启各自socket程序情况下, 断开ESTAB的TCP链接](https://segmentfault.com/a/1190000013365790)
    - 使用 iptables 与 tcpkill 关闭 established 状态的连接
2. [[Linux] 使用tcpkill杀掉tcp连接](https://www.cnblogs.com/taoshihan/p/13537361.html)
3. [tcpkill工作原理分析](https://github.com/stanzgy/wiki/blob/master/network/how-tcpkill-works.md)
    - 写得不错
4. [如何干掉一条tcp 连接（活跃/非活跃）](https://developer.aliyun.com/article/59308)
    - 指出了 tcpkill 的不足, 并提供了一个可以直接干掉连接的 v2 版本, 用起来很不错.
6. [使用killcx关闭Linux上的tcp连接](https://www.jianshu.com/p/61f6d7275335)

