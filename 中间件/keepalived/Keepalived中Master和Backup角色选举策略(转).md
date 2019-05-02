# Keepalived中Master和Backup角色选举策略(转)

原文链接

[Keepalived中Master和Backup角色选举策略](http://www.linuxidc.com/Linux/2014-08/105884.htm)

在Keepalived集群中, 其实并没有严格意义上的主、备节点, 虽然可以在Keepalived配置文件中设置`state`选项为`MASTER`状态, 但是这并不意味着此节点一直就是Master角色. 控制节点角色的是Keepalived配置文件中的`priority`值, 但并它并不控制所有节点的角色, 另一个能改变节点角色的是在`vrrp_script`模块中设置的`weight`值, 这两个选项对应的都是一个整数值, 其中`weight`值可以是个负整数, 一个节点在集群中的角色就是通过这两个值的大小决定的. 

在一个一主多备的Keepalived集群中, `priority`值最大的将成为集群中的`Master`节点, 其他都是`Backup`节点. 在Master节点发生故障后, Backup节点之间将进行"民主选举", 通过对节点优先级值`priority`和`weight`的计算, 选出新的`Master`节点接管集群服务. 

在`vrrp_script`模块中, **如果不设置`weight`选项值, 那么集群优先级的选择将由Keepalived配置文件中的`priority`值决定**, 而在需要对集群中优先级进行灵活控制时, 可以通过在`vrrp_script`模块中设置`weight`值来实现. 下面列举一个实例来具体说明. 

假定有A和B两节点组成的Keepalived集群, 在A节点`keepalived.conf`文件中, 设置`priority`值为100, 而在B节点`keepalived.conf`文件中, 设置`priority`值为80, 并且A、B两个节点都使用了`vrrp_script`模块来监控mysql服务, 同时都设置`weight`值为10, 那么将会发生如下情况. 

在两节点都启动Keepalived服务后, 正常情况是A节点将成为集群中的Master节点, 而B自动成为Backup节点. 然后此时将A节点的mysql服务关闭, 通过查看日志发现, 并没有出现B节点接管A节点的日志, B节点仍然处于Backup状态, 而A节点依旧是Master状态, 在这种情况下整个HA集群将失去意义. 

下面就分析一下产生这种情况的原因, 这也就是Keepalived集群中主、备角色选举策略的问题. 下面总结了在Keepalived中使用`vrrp_script`模块时整个集群角色的选举算法, 由于`weight`值可以是正数也可以是负数, 因此, 要分两种情况进行说明. 

**1.  "weight"值为正数时**

在`vrrp_script`中指定的脚本如果检测成功, 那么Master节点的权值将是"weight值与"priority"值之和, 如果脚本检测失败, 那么Master节点的权值保持为"priority"值, 因此切换策略为：

Master节点`vrrp_script`脚本检测失败时, 如果Master节点`priority`值小于Backup节点`weight`值与`priority`值之和, 将发生主、备切换. 

Master节点`vrrp_script`脚本检测成功时, 如果Master节点`weight`值与`priority`值之和大于Backup节点"weight"值与"priority"值之和, 主节点依然为主节点, 不发生切换. 

**2.  "weight"值为负数时**

在`vrrp_script`中指定的脚本如果检测成功, 那么Master节点的权值仍为`priority`值, 当脚本检测失败时, Master节点的权值将是"priority"值与"weight"(绝对)值之差, 因此切换策略为：

Master节点`vrrp_script`脚本检测失败时, 如果Master节点"priority"值与"weight"值之差小于Backup节点"priority"值, 将发生主、备切换. 

Master节点`vrrp_script`脚本检测成功时, 如果Master节点"priority"值大于Backup节点"priority"值时, 主节点依然为主节点, 不发生切换. 

在熟悉了Keepalived主、备角色的选举策略后, 再来分析一下刚才实例. 

由于A、B两个节点设置的"weight"值都为10, 因此符合选举策略的第一种, 在A节点停止Mysql服务后, A节点的脚本检测将失败, 此时A节点的权值将保持为A节点上设置的"priority"值, 即为100, 而B节点的权值将变为"weight"值与"priority"值之和, 也就是90（10+80）, 这样就出现了A节点权值仍然大于B节点权值的情况, 因此不会发生主、备切换. 

对于"weight"值的设置, 有一个简单的标准, 即**`weight`值的绝对值要大于Master和Backup节点"priority"值之差**. 对于上面A、B两个节点的例子, 只要设置"weight"值大于20即可保证集群正常运行和切换. 由此可见, 对于`weight`值的设置, 要非常谨慎, 如果设置不好, 将导致集群角色选举失败, 使集群陷于瘫痪状态. 