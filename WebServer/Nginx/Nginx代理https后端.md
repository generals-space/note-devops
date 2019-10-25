# Nginx代理https后端

参考文章

1. [kubernetes 之 master高可用集群搭建](https://cloud.tencent.com/developer/article/1450346)

这个需求是在搭建kubernetes, 使用nginx为集群中master节点的api-server做负载均衡和高可用时遇到的.

初始我的配置如下

```conf
http {
    upstream backend {
        server k8s-master-01:6443 max_fails=1 fail_timeout=10s;
        server k8s-master-02:6443 max_fails=1 fail_timeout=10s;
        server k8s-master-03:6443 max_fails=1 fail_timeout=10s;
    }
    server {
        listen 8443;
        location / {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://backend;
        }
    }
}
```

但是在访问nginx的8443端口时, 出现如下错误

```
curl: (35) error:1408F10B:SSL routines:ssl3_get_record:wrong version number
```

我最初以为是`proxy_pass`字段的前缀应该是`https://`才行, 但是修改后并没有变化.

后来找到了参考文章1(并不是...), 其中nginx配置与上面的不太一样.

```conf
stream {
    upstream kube-apiserver {
        least_conn;
        server k8s-master-01:6443 max_fails=1 fail_timeout=10s;
        server k8s-master-02:6443 max_fails=1 fail_timeout=10s;
        server k8s-master-03:6443 max_fails=1 fail_timeout=10s;
    }

    server {
        listen 8443;
        proxy_connect_timeout 1s;
        proxy_timeout 30m;
        proxy_pass kube-apiserver;
        ## 注意: 这里的 proxy_pass 是直接放在server块下的,
        ## 而且不是 http 模块, 而是 stream 块.
        ## 因为后端是 https, 只能使用 4 层转发, 否则无法传输证书.
    }
}
```

于是我知道了`stream{}`块, 与`http{}`的概念平级, 但是是4层转发, 只有这样才能正确代理后端的https接口.
