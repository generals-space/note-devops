# tap&tun

参考文章

1. [详解云计算网络底层技术——虚拟网络设备 tap/tun 原理解析](https://www.cnblogs.com/bakari/p/10450711.html)
    - tap/tun的概念与区别
2. [Linux 网络工具详解之 ip tuntap 和 tunctl 创建 tap/tun 设备](https://www.cnblogs.com/bakari/p/10449664.html)
    - `ip tuntap`创建tap和tun设备的操作方式(还有`tunctl`这个命令, 不再建议使用)
3. [利用 Linux tap/tun 虚拟设备写一个 ICMP echo 程序](https://www.cnblogs.com/bakari/p/10474600.html)
    - 以上三篇属于同一作者
4. [Linux内核网络设备——tun、tap设备](http://blog.nsfocus.net/linux-tun-tap/)
    - tcp/ip协议栈分层和netdevice子系统, ASCII模型图, 比较详细
    - C语言测试代码...不过是图片版的
5. [Linux虚拟网络设备之tun/tap](https://segmentfault.com/a/1190000009249039)
    - 同样是ASCII模型图
    - C语言测试代码
6. [Linux的TUN/TAP编程](http://blog.chinaunix.net/uid-317451-id-92474.html)
    - `lsmod | grep tun`查看是否加载tun驱动

参考文章3, 4, 5都有用C语言模拟`tun`设备的示例, 实践可行, 记录下使用步骤

## 编译C程序

编译

```
gcc -o tun tun.c
```

得到可执行文件`tun`, 运行

```console
$ ./tun
Open tun/tap device: tun0 for reading...
```

这个程序启动后, 会自动创建`tun0`网络设备(如果多次运行, 还会依次创建`tun1`, `tun2`...)

> 程序结束后, `tun0`设备会自动移除.

## 启动 tun 设备

使用`ip`命令为`tun0`设备赋予IP地址, 可随意指定, 一般是一个不存在的网络, 如`10.18.0.2/24`.

```
ip addr add 10.18.0.2/24 dev tun0
```

上一步程序创建的`tun0`设备默认为`DOWN`的状态, 我们需要手动将其启动.

```
ip link set tun0 up
```

启动后使用`ip r`, 可以看到路由表中多了如下表项

```
10.18.0.0/24 dev tun0 proto kernel scope link src 10.18.0.2
```

## ping

ping这个`tun0`设备IP所在网段的其他IP(比如10.18.0.3), 这些包会根据上面新增的路由表流经`tun0`设备, 不过当然是ping不通的, 因为数据包到了`tun0`, 就被我们的程序读取到了, 于是我们的程序有如下输出.

```
Open tun/tap device: tun0 for reading...
Read 48 bytes from tun/tap device
Read 48 bytes from tun/tap device
```

> 使用`tcpdump`监听这个`tun0`设备, 可以看到ping的请求包(没有响应包).

