# Keepalived配置(二)-进阶

## 1. nopreempt不抢占

两个节点, 一主一备, 主节点的`priority`值比较高. 如下

主节点

```conf
global_defs {  
    ## 表示运行Keepalived服务器的一个标识, 名称而已, 不会冲突
    router_id nodeA  
}
## 监测实例名 VI_1
vrrp_instance VI_1 {  
    state MASTER    #设置为主服务器  
    interface eth0  #监测网络接口  
    virtual_router_id 51  #该值可以随意, 但是主、备必须一样. 注意不要与其他keepalived组冲突  
    priority 100   #(主、备机取不同的优先级，主机值较大，备份机值较小,值越大, 切换时优先级越高, 多主机时会很有用)  
    advert_int 1   # VRRP Multicast广播周期秒数  
    authentication {  
        auth_type PASS  #VRRP认证方式，主备必须一致  
        auth_pass 1111   #(密码)  
    } 
    virtual_ipaddress {  
        192.168.8.100/24  #VRRP HA虚拟IP地址, 不能被其他主机占用, 否则会冲突  
    }
}
```

从节点

```
state BACKUP
priority 90
```

这种情况下, 当主节点A挂掉, 从节点B提升为主节点获取到虚拟IP, 当原主节点A恢复正常, 就立刻恢复了主节点的身份, B又被降成从节点. 主从切换频繁, 同步数据将对业务造成影响, 这并不是我们想看到的.

如果不想业务频繁切换, 需要对**主节点配置**作如下修改:

```
state BACKUP
nopreempt
```

`nopreempt`意为不抢占, 但只对`BACKUP`角色有效.

但是, 要注意, 如果使用这种方式, 最初的启动顺序是十分有关系的, 这会让第一个启动的`keepalived`成为主节点. 如果在业务层面上最初主从节点数据不一致而又先启动了从节点, 主节点的数据将被覆盖, 这很危险!!!

## 2. 事件触发

- notify_master: `keepalived`由从节点提升到主节点时触发此操作, 注意, 第一个keepalived节点启动时它会自动判断自己是主节点, 也会触发这个操作.

- notify_backup: 原理同上, 最初启动时就得到从节点的角色也会触发此操作

- notify_fault: keepalived主从切换出现问题时触发

- notify_stop: keepalived监测脚本(`vrrp_script`块中定义)返回非0状态码时触发此操作

- notify: 所有事件都会触发这个操作, 并且在上面4个操作之后执行

注意点:

1. `notify_*`字段在`vrrp_instance`块内

2. `notify_* 脚本路径`, 其中脚本路径可以直接写绝对路径, 需要带参数的脚本可以使用双引号包裹起来, 但不能使用单引号

```
notify_master "/etc/keepalived/scripts/master.sh 127.0.0.1" 对
notify_master /etc/keepalived/scripts/master.sh 对
notify_master '/etc/keepalived/scripts/master.sh' 错
```

3. 事件触发需要关闭SELinux, 否则将无法执行目标脚本

4. 记得要为目标脚本添加可执行权限