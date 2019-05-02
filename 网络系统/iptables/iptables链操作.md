# iptables链操作

## 1. 修改指定链默认规则

语法: `iptables [-t table名] -P 链名 规则(一般为DROP, ACCEPT等)`

```
$ iptables -P INPUT DROP
```

## 2. 查看指定链规则

```
$ iptables [-t {nat|filter}] --list-rules 链名 
```

说明: 不必添加`-L`选项, 可以查看目标链中的规则与子链名称(但不可查看子链下的规则). 若不指定链名, 将打印出当前表中所有规则.

示例

```
$ iptables --list-rules INPUT
-P INPUT ACCEPT
-A INPUT -i virbr0 -p udp -m udp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p udp -m udp --dport 67 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 67 -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -j INPUT_direct
-A INPUT -j INPUT_ZONES_SOURCE
-A INPUT -j INPUT_ZONES
-A INPUT -p icmp -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
```

其中`INPUT_direct`, `INPUT_ZONES_SOURCE`等INPUT的子链哦.

不过貌似子链是没有默认规则的, 只能遵循父链规则. 毕竟子链可能不会是数据包的终点.

## 3. 添加自定义链

### 3.1 创建新链

练习之前首先清空已经存在的规则. **注意: 正式场景中不可进行如下操作**

```
## 清空filter表
$ iptables -F                           ## -F参数会清空所有链(包括子链)下的规则
$ iptables -X                           ## -X会删除除默认链之外的所有空链(非空的也删不掉)
$ iptables -Z
$ iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination  
## 清空nat表       
$ iptables -t nat -F
$ iptables -t nat -X
$ iptables -t nat -Z
$ iptables -t nat -L
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination       
```

然后进行实际操作, 尝试创建, 修改, 删除自定义链.

新建一条空链docker(默认在filter表上)

```
$ iptables -N docker
$ iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain docker (0 references)
target     prot opt source               destination
```

修改链名称, 将docker修改为vpn

```
$ iptables -E docker vpn
$ iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain vpn (0 references)
target     prot opt source               destination   
```

删除空链vpn, 如果自定义链不为空, 则只能先将其清空, **无法直接删除**

```
$ iptables -X vpn
$ iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination    
```

### 3.2 挂载子链

单纯创建空链是没有意义的, 自定义链的意义在于, 更加结构化地描述, 管理访问规则. 比如安装docker时, docker服务将创建属于它自己的iptables链, 所有的规则写在自定义链里. 卸载docker时, 只要清空docker链, 然后删除空链即可.

为了能使自定义链生效, 我们还需要将自定义链挂到某一默认链上, 否则网络请求是不会流经我们的自定义链的.

创建docker链

```
$ iptables -N docker
$ iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain docker (0 references)
target     prot opt source               destination   
```

将docker链挂到INPUT链下, 这里可以使用`-t`选项指定其他表, 也可以使用与`-A`同级的`-I`选项, 指定其他链名. `-j`选项不再是原来的`ACCEPT`或是`DROP`了, 它的值就是我们的自定义链名, 这样就将规则交由子链处理.

```
$ iptables -A INPUT -j docker
```

INPUT链下有了target列为docker的行, 并且docker链后面显示了`1 references`(原来是0)  

```    
$ iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
docker     all  --  anywhere             anywhere            

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain docker (1 references)
target     prot opt source               destination       
```

### 3.3 测试子链规则

然后尝试在docker链中添加一条规则检查是否生效. 当前所有链都为空, 默认不会存在端口屏蔽的情况. 在iptables主机上执行如下命令, 监听5000端口.

```
$ nc -l 0.0.0.0 5000
```

然后在其他主机上执行如下命令连接iptables主机的5000端口, 原则上是能正常连接并且之后可以通信的.

```
$ nc iptables主机的IP 5000
```

现在我们在docker链上屏蔽5000端口, 观察是否还能从其他主机上连接进来

```
$ iptables -A docker -p tcp --dport 5000 -j DROP
$ iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
docker     all  --  anywhere             anywhere            

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain docker (1 references)
target     prot opt source               destination         
DROP       tcp  --  anywhere             anywhere             tcp dpt:commplex-main
```

再次执行上述nc命令, 会发现无法再从其他主机上连接到iptables主机的5000端口(连接时显示timeout, 因为iptables主机上的drop规则会悄悄丢弃请求包, 也不会明确拒绝)

然后清空docker链并删除它

```
## docker链不为空时删除会报错
$ iptables -X docker
iptables: Too many links.
## -F选项不加链名的话会清空当前表中所有链的规则
$ iptables -F docker
## 还要记得docker挂在了INPUT链上, 所以还要将其从INPUT移除
$ iptables -D INPUT 1
$ iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
docker     all  --  anywhere             anywhere            

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain docker (1 references)
target     prot opt source               destination         
## 删除链
$ iptable -X docker
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
DROP       tcp  --  anywhere             anywhere             tcp dpt:terabase

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination  
```

完成.