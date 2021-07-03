## 1. 在CentOS8.0中默认不再支持ntp软件包，时间同步将由chrony来实现.

参考 [CentOS8.0通过yum安装ntp同步时间](https://blog.whsir.com/post-4925.html), 通过wlnmp源安装ntp服务.

## 2. 移除network服务, 只保留NetworkManager.

- [基于RHEL8/CentOS8的网络IP配置详解](https://zhuanlan.zhihu.com/p/56892392)
    - 详细, 理论派, nmcli命令应用
- [Centos8 配置静态IP](https://www.cnblogs.com/qianyuliang/p/11591970.html)
    - 实践应用

## 3. 没有ntpdate工具, 取代的是chronyd服务

systemctl start chronyd
systemctl enable chronyd
chronyc sources

功能类似于 `ntpdate asia.pool.ntp.org`
