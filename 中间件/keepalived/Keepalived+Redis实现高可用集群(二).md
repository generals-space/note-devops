# Keepalived+Redis实现高可用集群(二)

## 1. 云主机部署keepalived

参考文章

[阿里云下配置keepalive，利用HAVIP实现HA](https://yq.aliyun.com/articles/24155)

[阿里云服务器不能使用keepalived，那么阿里云服务器如何实现mysql高可用呢？](https://www.zhihu.com/question/48164814)

情况描述

在金山云的两台VPC服务器之间搭建keepalived+Redis高可用集群. 两者使用内网ip通信, 可以互相ping通过, arp也能够正确保存对方的mac地址与IP地址, 但是启动keepalived后两台主机都得到了虚拟IP, 因为日志显示两者之间没有通信.

原因分析

云服务器ECS一般不支持浮动IP, 因为它们不支持组播和广播.

阿里云有`HAVip(高可用虚拟IP的解决方案)`, 不过没有机会实验, 在金山云上没有找到类似的功能.

说来其实组播,广播与`vrrp`协议本身没有关系, 使用vrrp协议进行单播还是可以的.

解决办法

keepalived支持单播模式, 可以指定vrrp报文的源IP与目的IP, 使这两台服务器单独通信.

`unicast`的源IP与目标IP在两台服务器上需要相反, 并且与`interface`指定的网卡所绑定的IP对应(...我猜的), 比如下面的`10.0.0.1`就是这台服务器上`eth0`网卡所绑定的IP.

```
vrrp_instance 虚拟路由名称{
    interface eth0
    ## 单播源IP
    unicast_src_ip  10.0.0.1
    unicast_peer {
        ## 单播目标IP
        10.0.0.2
    }
    ...
    authentication {   
        auth_type PASS   
        auth_pass 1111
    }
    ...
}
```

## 2. 多实例监听

参考文章

[keepalived工作原理和配置说明 腾讯云VPC内通过keepalived搭建高可用主备集群](http://www.cnblogs.com/MYSQLZOUQI/p/5833998.html)

情景描述

两台服务器, 使用一对`keepalived`保证两组redis主从服务(这里称为A1与A2, B1与B2)的故障转移.

需要注意的是, 如果A1这个redis服务挂掉, keepalived需要让A2对外服务, 但是不能影响B1与B2正常运行.

所以需要**两个虚拟IP**, 分别给这两组redis使用. 结构与单组redis相同, 不过由于两组redis需要监听不同端口, 所以脚本也需要重新指定.

解决办法

keepalived.conf结构如下

```
! Configuration File for keepalived

global_defs {
   router_id HARedis
}
## 定义监控脚本
vrrp_script redis_check_6379 { 
     script "/etc/keepalived/scripts/redis_6379/redis_check.sh" 
     ...
}

vrrp_instance HARedis_6379 {
    ...
    virtual_ipaddress {  
        10.0.0.100/24
    }
    ## 服务监控脚本, 这里的名称是上面vrrp_script块定义的
    track_script {
	redis_check_6379
    } 
    ...
}

vrrp_script redis_check_6389 { 
    script "/etc/keepalived/scripts/redis_6389/redis_check.sh" 
    ...
}

vrrp_instance HARedis_6389 {
    virtual_ipaddress {  
        10.0.0.101/24
    }
    ## 服务监控脚本, 这里的名称是上面vrrp_script块定义的
    track_script {
	redis_check_6389
    } 
    ...
```

keepalived配置文件目录如下, 为redis不同实例设置不同目录(注意`redis_include.sh`中的端口).

```
.
├── keepalived.conf
└── scripts
    ├── redis_6379
    │   ├── redis_backup.sh
    │   ├── redis_check.sh
    │   ├── redis_include.sh
    │   └── redis_master.sh
    └── redis_6389
        ├── redis_backup.sh
        ├── redis_check.sh
        ├── redis_include.sh
        └── redis_master.sh

3 directories, 9 files
```