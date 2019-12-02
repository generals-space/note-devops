# Nginx-upstream超时调整

参考文章

1. [Module ngx_http_proxy_module](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)
    - 官方文档 proxy模块可用指令及默认值
2. [NGINX配置超时时间](https://my.oschina.net/xsh1208/blog/199674)
    - 从使用者的角度描述这些指令的涵义


```
location / {
    proxy_pass http://upstream名称;

    proxy_connect_timeout                   300s;
    proxy_send_timeout                      300s;
    proxy_read_timeout                      300s;
}
```
