# Keepalived+Redis多组实例高可用

如果一组集群中需要通过keepalived完成多组redis(当然是不同端口的实例)的高可用配置, 如何做到?

我们需要考虑到, 其中一组redis的某一个节点故障时的主从切换不会影响到另外一组正常状态的redis集群的运行.

一个解决的思路是, 使用多个虚拟IP. 即为每一组redis集群通过不同的虚拟IP完成故障转移. (当然, 如果keepalived服务出了问题, 所有的虚拟IP都会发生变动的.)

假设两组redis服务分别监听6379与6389端口. `keepalived.conf`的配置如下

```
## 定义监控脚本
vrrp_script redis_check_6379 {                                      ## 监控块不同
     script "/etc/keepalived/scripts/redis_6379/redis_check.sh"     ## 不同redis进程的检测脚本需要不同, 因为它们端口不一样
     interval 2 ## 执行间隔
     timeout 2  ## 每2s执行一次监控脚本
     fall 3
}

vrrp_instance HARedis_6379 {                                        ## 通过这里进行区分不同redis服务, 也是区分不同的虚拟IP
    ## 主从都配置为BACKUP
    state BACKUP
    interface eth0
    virtual_router_id 50                                            ## 不同服务的virtual_route_id必须不同
    priority  150                                                   ## 不同服务的优先级可以不同, 但差值最好一样都是50好了.
    ## 不抢占，注意加上
    nopreempt
    advert_int 1        
    authentication {   
        auth_type PASS   
        auth_pass 1111
    }
    virtual_ipaddress {  
        172.17.0.100/24                                             ## 虚拟IP也要不同.
    }
    ## 服务监控脚本, 这里的名称是上面vrrp_script块定义的
    track_script {
         redis_check_6379
    } 
    ## slave提升为master时执行的操作, 有参数需要空格时用引号包裹起来
    notify_master "/etc/keepalived/scripts/redis_6379/redis_master.sh"
    ## master降为slave时执行的操作
    notify_backup "/etc/keepalived/scripts/redis_6379/redis_backup.sh"
    ## keepalived所监控的服务出问题时执行的操作
    notify_stop "/etc/keepalived/scripts/redis_6379/redis_backup.sh"
    ## keepalived出现问题时执行的操作
    notify_fault "/etc/keepalived/scripts/redis_6379/redis_backup.sh"
}

## 定义监控脚本
vrrp_script redis_check_6389 {                                      ## 监控块不同
     script "/etc/keepalived/scripts/redis_6389/redis_check.sh"     ## 不同redis进程的检测脚本需要不同, 因为它们端口不一样
     interval 2 ## 执行间隔
     timeout 2  ## 每2s执行一次监控脚本
     fall 3
}

vrrp_instance HARedis_6389 {                                        ## 通过这里进行区分不同redis服务, 也是区分不同的虚拟IP
    ## 主从都配置为BACKUP
    state BACKUP
    interface eth0
    virtual_router_id 55                                            ## 不同服务的virtual_route_id必须不同
    priority  140                                                   ## 不同服务的优先级可以不同, 但差值最好一样都是50好了.
    ## 不抢占，注意加上
    nopreempt
    advert_int 1        
    authentication {   
        auth_type PASS   
        auth_pass 1111
    }
    virtual_ipaddress {  
        172.17.0.110/24                                             ## 虚拟IP也要不同.
    }
    ## 服务监控脚本, 这里的名称是上面vrrp_script块定义的
    track_script {
         redis_check_6389
    } 
    ## slave提升为master时执行的操作, 有参数需要空格时用引号包裹起来
    notify_master "/etc/keepalived/scripts/redis_6389/redis_master.sh"
    ## master降为slave时执行的操作
    notify_backup "/etc/keepalived/scripts/redis_6389/redis_backup.sh"
    ## keepalived所监控的服务出问题时执行的操作
    notify_stop "/etc/keepalived/scripts/redis_6389/redis_backup.sh"
    ## keepalived出现问题时执行的操作
    notify_fault "/etc/keepalived/scripts/redis_6389/redis_backup.sh"
}

```

可以看到, 与之前相比, `global_defs`块的`router_id`字段没有了, 但是对keepalived服务没有任何影响.

最佳实践是, 在`$keepalived/scripts`目录下按照不同服务建立独立目录(这里分别是`redis_6379`和`redis_6389`)来存放目标脚本. 实际上变动的只`redis_include.sh`脚本, 因为虚拟IP与监听端口都是在这里配置的. 当然, 日志文件名称最好也要有所区别.