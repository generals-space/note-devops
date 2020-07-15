# HAProxy应用场景

```conf
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
