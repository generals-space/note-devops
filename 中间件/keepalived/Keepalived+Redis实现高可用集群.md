# Keepalived+Redis实现高可用集群

## 1. 引言

参考文章

[Redis+Keepalived高可用方案详细分析](https://my.oschina.net/guol/blog/182491)

redis自2.8开始, 实现了`sentinel`机制, 以实现主从自动发现与故障转移; 从3.0开始实现`cluster`机制, 实现了数据分片与负载均衡. 但是程序级别需要标注多个`redis`实例IP, 以方便某个实例故障时可以将请求转发至其他已知节点.

以php的Predis模块为例

```
<?php
	require_once 'Predis/src/Autoloader.php';
   	Predis\Autoloader::register();
    //redis集群配置
	$cluster = array(
		'tcp://172.17.0.4:6381', 
		'tcp://172.17.0.4:6382', 
		'tcp://172.17.0.5:6383', 
		'tcp://172.17.0.5:6384', 
		'tcp://172.17.0.6:6385', 
		'tcp://172.17.0.6:6386', 
	);
	$options = array(
		'cluster' => 'redis',
	);
	$client = new Predis\Client($cluster, $options);
    
	$client->set('key1', 'val1');
	$client->set('key2', 'val2');
	$client->set('key3', 'val3');
	$client->set('key4', 'val4');
	$client->set('key5', 'val5');
	$client->set('key6', 'val6');
    
	$value = $client->get('key1');
	echo $value."\n";
	$value = $client->get('key2');
	echo $value."\n";    
	$value = $client->get('key3');
	echo $value."\n";    
	$value = $client->get('key4');
	echo $value."\n";    
	$value = $client->get('key5');
	echo $value."\n";    
	$value = $client->get('key6');
	echo $value."\n";

    $mkv  =  array ( 
        '{usr}.user1'  =>  'First user' , 
        '{usr}.user2'  =>  'Second user' , 
    ) ; 
    //高版本predis可实现更多更复杂的redis命令
    $client -> mset ($mkv) ; 
    $value = $client->get('{usr}.user1');
    echo $value."\n";
    $value = $client->mget('{usr}.user1', '{usr}.user2');
    echo $value[1]."\n";
?>
```

该集群中包含6个节点, 3主3备, 任何单一主/备节点故障都不会影响集群工作. 但是如果程序所用redis接口不支持多IP配置, 或是有些命令不包含在该接口中(比如`hscan`), 就不能使用这种方案, 尤其是时间不充分, 修改/测试风险较高的情况下, 只能从运维层面以最简单的redis主从模式实现高可用.

------

## 2. 环境准备

`Keepalived+Redis`高可用原理是, keepalived运行期间, 每隔一段时间执行一次redis存活检测的脚本(需要自行编写), 该脚本的返回值将作为keepalived对redis实例存活判断的依据. keepalived将根据这个结果执行对当前keepalived主/从节点的特定的升级/降级操作(实现主从切换的redis脚本也是需要自行编写的)

需要注意的是, 这其中有两种主备角色, keepalived有它自己确定的主备节点, 区别在于keepalived主节点拥有虚拟IP的MAC映射; redis也有主备节点, 区别在于主节点可读可写, 而从节点只可读. 一般来说, 建好的`keepalived+redis`高可用集群中, 这两种服务的主节点角色是相同的(keepalived主节点上运行的redis也是主节点). 

测试环境:

keepalived: 1.2.13

redis: 3.0.7

- 节点A: 172.17.0.11

- 节点B: 172.17.0.12

- 节点C: 172.17.0.13

- 虚拟IP: 172.17.0.100

## 3. 流程规划

> 最初始时, 依次启动各个节点上的`keepalived`与`redis`实例. 注意, redis集群的主从关系不是手动设置的, 而是`keepalived`对`redis`实例运行状况进行检测后执行相应的脚本设置的. 这样可以保证数据一致性, 原从节点的数据不会覆盖主节点.

1. A节点启动keepalived与redis, keepalived取得预置的虚拟IP, 成为主节点, 同时执行`notify_master`操作, 对本地redis实例执行`slaveof no one`, 提升为主节点.

2. B, C节点启动keepalived与redis, keepalived得到集群中已存在主节点, 于是自动获得从节点角色, 执行`notify_backup`操作, 使本地redis实例成为虚拟IP所指的redis实例的从节点(因为虚拟IP所在节点必然是主节点).

3. 当某keepalived服务本身故障, 会被其他keepalived检测到, 如该keepalived本来就是从节点(B或C), 将不会有任何变化; 如果它原来是主节点(比如初始的A节点), 其他keepalived会重新选出一个主节点, 新的主节点得到虚拟IP, 其他的从节点的redis实例只会以虚拟IP所指的redis实例为主节点. 而原来的主节点服务器上的redis虽然还是主节点, 但请求已经不能被转发到这里了.

4. (猜测)如果redis实例出现问题, keepalived会通过我们自行指定的监测脚本发现故障, 自动退至从节点角色. 然后执行`notify_backup`操作, 作为新的主节点的redis实例的从节点继续工作(虽然此时其redis已经挂了, 但并不影响新主节点的正常运行).

5. (猜测)当出故障的redis实例恢复正常, keepalived会检测到并自动执行`notify_backup`操作退至从节点角色而不是去抢占成为主节点.

keepalived的配置如下, **不同节点上只有`priority`的值不同, 其他的完全一样**. 自定义脚本方面只需要配置`redis_include.sh`, 这样不必在`keepalived.conf`中调用脚本时使用不同参数, 容易出错, 并且还支持一主多备的形式.

```conf
global_defs {
   router_id HARedis
}
## 定义监控脚本
vrrp_script redis_check { 
     script "/etc/keepalived/scripts/redis_check.sh" 
     interval 2 ## 执行间隔
     timeout 2  ## 每2s执行一次监控脚本
     fall 3
}

vrrp_instance HARedis {
    ## 主从都配置为BACKUP
    state BACKUP
    interface eth0
    virtual_router_id 55
    ## 不同服务的优先级可以不同, 但差值最好一样都是50好了.
    priority  150       
    ## 不抢占，注意加上
    nopreempt
    advert_int 1        
    authentication {   
        auth_type PASS   
        auth_pass 1111
    }
    virtual_ipaddress {  
        172.17.0.100/24
    }
    ## 服务监控脚本, 这里的名称是上面vrrp_script块定义的
    track_script {
         redis_check 
    } 
    ## slave提升为master时执行的操作, 有参数需要空格时用引号包裹起来
    notify_master "/etc/keepalived/scripts/redis_master.sh"
    ## master降为slave时执行的操作
    notify_backup "/etc/keepalived/scripts/redis_backup.sh"
    ## keepalived所监控的服务出问题时执行的操作
    notify_stop "/etc/keepalived/scripts/redis_backup.sh"
    ## keepalived出现问题时执行的操作
    notify_fault "/etc/keepalived/scripts/redis_backup.sh"
}
```

------

下面是redis监控/切换脚本的编写. 注意**关闭SELinux并赋予这些脚本执行权限**.

**1. 全局定义脚本`redis_include.sh`**

定义了虚拟IP地址, redis集群的端口(需统一), 以及日志文件路径, 日志格式等信息. 这样就不用在`keepalived.conf`中写IP和端口信息了, 容易弄混.

```shell
#!/bin/bash

## redis_include.sh

## redis-cli可执行文件路径
REDIS_CLI='/usr/bin/redis-cli'
## 虚拟IP地址, 需要与keepalived.conf中的virtual_ipaddress字段值保持一致
VIR_IP=172.17.0.100
## redis集群所用端口, 需要所有节点上端口统一, 不然会很麻烦
REDIS_PORT=6379

## keepalived检测/切换日志文件
REDIS_HA_LOG='/var/log/keepalived-redis.log'

## 注意FORMATTED_DATE是date命令的执行结果, 为字符串类型, 要用反引号包裹
FORMATTED_DATE="date +'%Y-%m-%d:%H:%M:%S'"
## REDIS_STATUS也是字符串类型, 表示本地redis可用状态
REDIS_STATUS=$($REDIS_CLI -h 127.0.0.1 -p $REDIS_PORT PING)
```

**2. redis_check.sh**

redis监控脚本, keepalived将会根据此脚本的返回值确定是否触发`notify_backup`操作.

```shell
#!/bin/bash

## redis_check.sh

## keepalived调用脚本时, 脚本之间也必须写绝对路径才行
source $(dirname $0)/redis_include.sh

echo "[CHECK] $(eval $FORMATTED_DATE)" >> $REDIS_HA_LOG

if [ "$REDIS_STATUS" == "PONG" ]; then
  echo "PING -> $REDIS_STATUS" >> $REDIS_HA_LOG   2>&1
  exit 0
else
  echo "PING -> Failed" >> $REDIS_HA_LOG     2>&1
  exit 1
fi
```

**3. redis_master.sh**

`keepalived`成为主节点时调用此脚本, 使用`slaveof no one`让本地上的redis实例成为主节点

```shell
#!/bin/bash

## redis_master.sh

## keepalived调用脚本时, 脚本之间也必须写绝对路径才行
source $(dirname $0)/redis_include.sh

echo "[Master] $(eval $FORMATTED_DATE)" >> $REDIS_HA_LOG

## 将本地redis节点提升为主节点
$REDIS_CLI -h 127.0.0.1 -p $REDIS_PORT slaveof no one >> $REDIS_HA_LOG 2>&1
```

**4. redis_backup.sh**

本机redis实例故障, 或是keepalived成为从节点时调用此脚本, 将使本机的redis成为虚拟IP上的redis实例的从节点

```shell
#!/bin/bash

## redis_backup.sh

## keepalived调用脚本时, 脚本之间也必须写绝对路径才行
source $(dirname $0)/redis_include.sh

echo "[Slave] $(eval $FORMATTED_DATE)" >> $REDIS_HA_LOG

## 将本地redis节点作为$VIR_IP, $REDIS_PORT端口所指redis实例的从节点, 默认同一redis集群端口相同, 不然会很麻烦
$REDIS_CLI -p $REDIS_PORT slaveof $VIR_IP $REDIS_PORT >> $REDIS_HA_LOG  2>&1
```

## 4. 测试

注意: 

1. 需要先启动redis进程, 再启动keepalived服务

2. 最先同时启动`keepalived+redis`的节点将成为集群中的主节点(单独启动任意一个都不行哦), 之后启动的都将作为其从节点. 

kill掉其中任意一个redis实例或keepalived服务都可以实现完美切换, 而且不存在抢占的问题.

`redis_include.sh`中定义的检测日志格式如下

```
[CHECK] 2017-08-26:02:33:24
PING -> PONG
...
[CHECK] 2017-08-26:02:34:14
PING -> Failed
```
