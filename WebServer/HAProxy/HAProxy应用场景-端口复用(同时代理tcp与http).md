# HAProxy应用场景-端口复用(同时代理tcp与http)

参考文章

1. [80端口复用：利用haproxy把http流量和ssh流量分别转发到web服务器和ssh服务器](http://blog.csdn.net/zebra2011/article/details/51225262)
2. [Haproxy实战：80端口转发到webserver和ssh](http://blog.csdn.net/jmlikun/article/details/50605162)

> 同一端口同时代理TCP/HTTP, 根据访问协议判断. 比如让HA监听80端口分析连接协议, 如果是http协议就让服务器交给http服务程序(如Apache、Nginx等)处理, 如果是ssh协议就交给ssh服务程序（如OpenSSH Server）处理.

```conf
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

```conf
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
