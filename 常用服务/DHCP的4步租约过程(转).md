# DHCP的4步租约过程(转)

原文链接

[图解DHCP的4步租约过程](https://blog.51cto.com/yuanbin/109574)

DHCP租约过程就是DHCP客户机动态获取IP地址的过程. 

DHCP租约过程分为4步：

1. 客户机请求IP(客户机发`DHCPDISCOVER`广播包); 
2. 服务器响应(服务器发`DHCPOFFER`广播包); 
3. 客户机选择IP(客户机发`DHCPREQUEST`广播包); 
4. 服务器确定租约(服务器发`DHCPACK`/`DHCPNAK`广播包)

## 第1步：客户机请求IP

客户机请求IP, 也称为`DHCPDISCOVER`. 

当一个DHCP客户机启动时, 会自动将自己的IP地址配置成`0.0.0.0`, 由于使用`0.0.0.0`不能进行正常通信, 所以客户机就必须通过DHCP服务器来获取一个合法的地址. 由于客户机不知道DHCP服务器的IP地址, 所以它使用`0.0.0.0`的地址作为源地址, 使用**UDP/68**端口作为源端口, 使用`255.255.255.255`作为目标地址, 使用**UDP/67**端口作为目的端口来广播请求IP地址信息(见图一). 广播信息中包含了DHCP客户机的MAC地址和计算机名, 以便使DHCP服务器能确定是哪个客户机发送的请求. 

**DHCP客户机总是试图重新租用它接收过的最后一个IP地址, 这给网络带来一定的稳定性.**

![图一：客户机请求IP](https://gitee.com/generals-space/gitimg/raw/master/7c80332d7e7c1ad89c9106e14a0c30c2.gif)

## 第2步：服务器响应

服务器响应, 也称为`DHCPOFFER`. 

当DHCP服务器接收到客户机请求IP地址的信息时, 它就在自己的IP地址池中查找是否有合法的IP地址提供给客户机. 如果有, DHCP服务器就将此IP地址做上标记, 加入到DHCPOFFER的消息中, 然后DHCP服务器就广播一则包括下列信息的DHCPOFFER消息：

- DHCP客户机的MAC地址; 
- DHCP服务器提供的合法IP地址; 
- 子网掩码; 
- 默认网关(路由); 
- 租约的期限; 
- DHCP服务器的IP地址. 

因为DHCP客户机还没有IP地址, 所以DHCP服务器使用自己的IP地址作为源地址, 使用**UDP/67**端口作为源端口, 使用`255.255.255.255`作为目标地址, 使用`UDP/68`端口作为目的端口来广播DHCPOFFER信息(见图二). 

![图二：服务器响应](https://gitee.com/generals-space/gitimg/raw/master/0b4a8d522a84a1deae2c91f124520ece.gif)

## 第3步：客户机选择IP

客户机选择IP, 也称为`DHCPREQUEST`. 

DHCP客户机从接收到的第一个`DHCPOFFER`消息中选择IP地址, 发出IP地址的DHCP服务器将该地址保留, 这样该地址就不能提供给另一个DHCP客户机. 当客户机从第一个DHCP服务器接收`DHCPOFFER`并选择IP地址后, DHCP租约的第三过程发生. 客户机将`DHCPREQUEST`消息广播到所有的DHCP服务器, 表明它接受提供的内容. `DHCPREQUEST`消息包括为该客户机提供IP配置的服务器的服务标识符(IP地址). DHCP服务器查看服务器标识符字段, 以确定它自己是否被选择为指定的客户机提供IP地址, 如果那些`DHCPOFFER`被拒绝, 则DHCP服务器会取消提供并保留其IP地址以用于下一个IP租约请求. 

在客户机选择IP的过程中, 虽然客户机选择了IP地址, 但是还没有配置IP地址, 而在一个网络中可能有几个DHCP服务器, 所以客户机仍然使用`0.0.0.0`的地址作为源地址, 使用**UDP/68**端口作为源端口, 使用`255.255.255.255`作为目标地址, 使用**UDP/67**端口作为目的端口来广播DHCPREQUEST信息(见图三). 

![图三：客户机选择IP](https://gitee.com/generals-space/gitimg/raw/master/3c214de30c5811ce193adba52e5c050d.gif)

## 第4步：服务器确认租约

服务器确认租约, 也称为`DHCPACK`/`DHCPNAK`. 

DHCP服务器接收到`DHCPREQUEST`消息后, 以DHCPACK消息的形式向客户机广播成功的确认, 该消息包含有IP地址的有效租约和其他可能配置的信息. 虽然服务器确认了客户机的租约请求, 但是客户机还没有收到服务器的`DHCPACK`消息, 所以服务器仍然使用自己的IP地址作为源地址, 使用**UDP/67**端口作为源端口, 使用`255.255.255.255`作为目标地址, 使用UDP68端口作为目的端口来广播DHCPACK信息(见图四). 当客户机收到`DHCPACK`消息时, 它就配置了IP地址, 完成了TCP/IP的初始化. 

如果`DHCPREQUEST`不成功, 例如客户机试图租约先前的IP地址, 但该IP地址不再可用, 或者因为客户机移到其他子网, 该IP无效时, DHCP服务器将广播否定确认消息`DHCPNAK`. 当客户机接收到不成功的确认时, 它将重新开始DHCP租约过程. 

------

如果DHCP客户机无法找到DHCP服务器, 它将从TCP/IP的B类网段169.254.0.0中挑选一个IP地址作为自己的IP地址, 继续每隔5分钟尝试与DHCP服务器进行通讯, 一旦与DHCP服务器取得联系, 则客户机放弃自动配置的IP地址, 而使用DHCP服务器分配的IP地址. 

如果一台DHCP客户机有两个或者多个网卡, 则DHCP服务器会为每个网卡分配一个唯一而有效的IP地址. 

![图四：服务器确认租约](https://gitee.com/generals-space/gitimg/raw/master/fc50e7d4748c186c547739f1f946d9c0.gif)

DHCP服务器日志

![图五：DHCP服务器日志](https://gitee.com/generals-space/gitimg/raw/master/fe822597143128f1e9fddfb9a8818bbf.gif)

> 注：因为是虚拟机, 所以这个DHCP服务器的系统时间有些问题

DHCP客户机IP信息

![图六：DHCP客户机IP信息](https://gitee.com/generals-space/gitimg/raw/master/b9287fb8a58abc426eed5c1a243bdb97.gif)

可以看到客户端获取的IP地址是192.168.1.34; 默认网关是192.168.1.10; DHCP服务器IP是192.168.1.240; 租约时间是6个小时. 

## DHCP消息类型

1. DHCPDISCOVER 
2. DHCPOFFER 
3. DHCPREQUEST 
4. DHCPDECLINE 
5. DHCPACK 
6. DHCPNACK 
7. DHCPRELEASE
8. DHCPINFORM
