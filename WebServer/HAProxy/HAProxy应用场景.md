# HAProxy应用场景

## 1. HA代理mysql

HA相比于Nginx的优势之一就是 **TCP4层代理**, Nginx只能将请求以HTTP(s)/Mail协议转发给后端.

代理mysql, 来源限制就可以写在haproxy自己的配置文件里, 不必每当有一台新机器需要连接mysql时就在mysql中开放对这个IP的限制, 多麻烦.

示例配置1

```
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

```
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

## 2. 开启web检测页面

```
######## 统计页面配置 ############
listen admin_stats
    # 监听端口
    bind 0.0.0.0:1080
    # http的7层模式
    mode http
    # 日志设置
    log 127.0.0.1 local0 err
    # 统计页面自动刷新时间
    stats refresh 30s
    # 统计页面url
    stats uri /admin?stats
    # 统计页面密码框上的提示文本
    stats realm  Gemini\ Haproxy
    # 统计页面用户名和密码设置
    stats auth admin:123456
    # 隐藏统计页面上HAProxy的版本信息
    stats hide-version

#######网站检测listen定义############
listen site_status
    bind 0.0.0.0:1081
    mode http
    log 127.0.0.1 local0 err
    # 网站健康检测URL，用来检测HAProxy管理的后端网站是否可以用，正常返回200，不正常返回500
    monitor-uri /site_status
    # 定义网站down时的策略
    # 当挂在负载均衡上的指定backend的中有效机器数小于1台时返回true
    acl site_dead   nbsrv(backend_pool) lt 1
    # 当满足策略的时候返回500
    monitor fail if site_dead
    # 如果192.168.0.252或者192.168.0.31这两天机器挂了
    # 认为网站挂了，这时候返回500，判断标准是如果mode是
    # http返回200认为是正常的，如果mode是tcp认为端口畅通是好的
    monitor-net 192.168.0.252/31
```

## 3. 端口复用 - 同一端口同时代理TCP/HTTP, 根据访问协议判断

> 让HA监听80端口分析连接协议，如果是http协议就让服务器交给http服务程序（如Apache、Nginx等）处理，如果是ssh协议就交给ssh服务程序（如OpenSSH Server）处理.

参考文章

[80端口复用：利用haproxy把http流量和ssh流量分别转发到web服务器和ssh服务器](http://blog.csdn.net/zebra2011/article/details/51225262)

[Haproxy实战：80端口转发到webserver和ssh](http://blog.csdn.net/jmlikun/article/details/50605162)

```
listen custom
    mode tcp
    bind :8080
    tcp-request inspect-delay 2s
    ## 如果请求协议是http, 则is_http规则将返回true
    acl is_http req_proto_http
    tcp-request content accept if is_http
    server server名 http服务器IP:端口
    use_backend ssh-server if !is_http
backend ssh-server
    mode tcp
    server ssh服务器IP:22
```

更标准一点的写法是

```
frontend custom
    mode tcp
    bind 0.0.0.0:9010
    timeout client 1h
    tcp-request inspect-delay 2s
    ## 如果请求协议是http, 则is_http规则将返回true
    ## https没有实验过
    acl is_https req.payload(0,3) -m bin 160301  
    #GET POS(T) PUT DEL(ETE) OPT(IONS) HEA(D) CON(NECT) TRA(CE)   
    acl is_http req.payload(0,3) -m bin 474554 504f53 505554 44454c 4f5054 484541 434f4e 545241  
    #SSH, 但是这种请求头为匹配项的方法好像对ssh不起作用
    acl is_ssh req.payload(0,3) -m bin 535348  
    tcp-request content accept if is_http  
    tcp-request content accept if is_https  
    ## tcp-request content accept if is_ssh
    tcp-request content accept

    use_backend https-server if is_https
    use_backend http-server if is_http
    ## use_backend ssh-server if is_ssh
    use_backend ssh-server

backend https-server
    mode tcp
    server https-server-name 172.17.0.3:443
backend http-server
    mode tcp
    server http-server-name 172.17.0.3:80
backend ssh-server
    mode tcp
    server ssh-server-name 172.17.0.3:22
```

## 4. HA使用TCP代理转发记录客户端真实IP

USE_LINUX_TPROXY=1
