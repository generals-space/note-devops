# ip与ifconfig-网络接口设备的管理命令对照[promisc 混杂模式]

参考文章

1. [通过MacVLAN实现Docker跨宿主机互联](http://www.10tiao.com/html/357/201704/2247485101/1.html)
    - 混杂模式
2. [Linux TCP/IP网络小课堂：net-tools与iproute2大比较](https://os.51cto.com/art/201409/450886.htm)
    - `ip` VS ifconfig,route,arp,ipmaddr

| ifconfig               | ip                            | 操作类型                     |
| :--------------------- | :---------------------------- | :--------------------------- |
| ifconfig eth0 up/down  | ip link set dev eth0 up/down  | 启动/停止网络接口 eth0       |
| ifconfig eth0 promisc  | ip link set eth0 promisc on   | 设置网络接口 eth0 为混杂模式 |
| ifconfig eth0 -promisc | ip link set eth0 promisc off  | 取消网络接口 eth0 的混杂模式 |
| ifconfig eth0 mtu 1400 | ip link set dev eth0 mtu 1400 | 设置接口 eth0 的MTU值        |
