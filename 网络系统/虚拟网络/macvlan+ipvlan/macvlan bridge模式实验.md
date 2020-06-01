# macvlan bridge模式实验

参考文章

1. [Macvlan 网络方案实践](https://cloud.tencent.com/developer/article/1495218)
    - 使用macvlan连接两个netns的示例代码以及图示, 值得借鉴.

参考文章1中模拟了 macvlan 网络 bridge 模式下同主机不同 netns 间相互通信的流程. 看到最后, 就会发现整个流程与我自己写的 [cni-terway](https://github.com/generals-space/cni-terway)的流程基本相同, 就连为了实现`netns`中`macvlan`子接口与宿主机上的物理网卡直接通信, 做的也差不多. 

cni-terway是将物理网卡的IP移到bridge设备上, 而macvlan则要额外创建一个macvlan子接口, 还是要把物理网卡的IP移过去, 没差, 而且在IP迁移的时候都可能会造成网络中断. 这里就不重新模拟一遍了, 以后有机会再说吧.

