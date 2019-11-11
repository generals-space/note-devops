# nmcli命令应用

参考文章

1. [解决Centos网卡IP和配置文件不符的问题]（http://icestrawberryxjw.me/2019/03/06/ip-conf-file-inconsistency/)
    - device: 物理接口; connection: 逻辑接口.
2. [在 RHEL8 配置静态 IP 地址的不同方法](https://juejin.im/post/5d8cde1151882509662c5b9b)
    - 配置静态IP, 保存并重新加载网络配置文件.
3. [CentOS 7 下网络管理之命令行工具nmcli](https://www.jianshu.com/p/5d5560e9e26a)
    - connection对象可设置的属性列表: `nmcli c show 连接名称`

md刚刚差不多学会ip命令, CentOS 8又把network服务移除了.

