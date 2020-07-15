# HAProxy应用场景-4层代理mysql

HA相比于Nginx的优势之一就是 **TCP4层代理**, Nginx只能将请求以HTTP(s)/Mail协议转发给后端.

代理mysql, 来源限制就可以写在haproxy自己的配置文件里, 不必每当有一台新机器需要连接mysql时就在mysql中开放对这个IP的限制, 多麻烦.

示例配置1

```conf
global
        log 127.0.0.1 local0 info
        user haproxy
        group haproxy
        daemon
        nbproc 4
        pidfile /usr/local/haproxy/var/run/haproxy.pid
## main只是一个名称, 并列写的*:3306与`bind 0.0.0.0:3306`作用相同
frontend main 
        mode tcp
        bind *:3306
        option tcplog
        log global
        default_backend mysql_pool
backend mysql_pool
        mode tcp
        balance roundrobin
        option tcplog
        log global
        server mysql_server1 172.17.0.5:3306 check inter 1500 rise 3 fall 3 weight 1
```

这样可以完美完成端口转发的功能, 类似ssh也可以使用haproxy作为代理, 不知比iptables方便多少倍!

示例配置2(把`frontend`与`backend`写在单个`listen`块里)

```conf
global
        log 172.17.0.4 local0 info
        user haproxy
        group haproxy
        daemon
        nbproc 4
        pidfile /usr/local/haproxy/var/run/haproxy.pid
listen mysql 
        bind 0.0.0.0:3306
        mode tcp
        balance roundrobin
        option tcplog
        log global
        ## 可以写多个server段, 以实现负载均衡的目的
        server mysql_server1 172.17.0.5:3306 check inter 1500 rise 3 fall 3 weight 1
```
