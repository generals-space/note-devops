# bridge测试(三)-bridge+NAT使netns内部访问外网

参考文章

1. [Linux Namespace系列（06）：network namespace (CLONE_NEWNET)](https://segmentfault.com/a/1190000006912930)

## 1. 添加netns, 并创建veth对

创建netns的操作与其他大同小异, 创建veth设备后将一端移入netns, 并启动.

```
## 网络命令空间 net0
ip netns add net0
## 如下命令可以指定veth设备对的的名称, 否则将由os指定.
## ip link add veth0 type veth peer name veth1
ip link add type veth
ip link set dev veth1 netns net0

ip netns exec net0 ip link set dev veth1 name eth0
ip netns exec net0 ip addr add 10.1.1.2/24 dev eth0
## 注意即使这里启动了 eth0 接口, 自动添加了到 10.1.1.0/24 的路由
## 所以可以直接ping通对端 bridge 10.1.1.1
ip netns exec net0 ip link set dev eth0 up
```

veth的另一端(宿主机端)可以直接赋予一个同网段的ip, 如10.1.1.1

```
ip addr add 10.1.1.1/24 dev veth0
ip link set veth0 up
```

也可以连接到一个bridge设备, 注意这个设备也要赋予veth相同网段的IP并启动.

```
ip link add br0 type bridge
ip link set dev br0 up
ip addr add 10.1.1.1/24 dev br0
```

## 在netns中添加默认路由

via指定下一跳地址为宿主机端的veth地址

```
ip address add via 10.1.1.1 dev veth1 
```

## 开启宿主机的路由功能

```
sysctl -w net.ipv4.ip_forward=1
```

`ens32`为宿主机上可以访问外网的网络接口.

```
iptables -t nat -A POSTROUTING -o ens32 -j MASQUERADE
```
