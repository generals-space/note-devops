# macvlan bridge模式实验

参考文章

1. [Macvlan 网络方案实践](https://cloud.tencent.com/developer/article/1495218)
    - 使用macvlan连接两个netns的示例代码以及图示, 值得借鉴.
    - 将宿主机IP移到某个额外的 macvlan 设备上, 解决宿主机与容器间通信的问题.

1. 需要开启物理网卡的混杂模式

