参考文章

1. [nginx配置选项try_files详解](https://blog.csdn.net/zhuyongxin_6688/article/details/121408216)
1. [nginx try_files with a proxy_pass](https://gist.github.com/mattd/1006398/598df8f218a18bc1b0f3415550b4a369f37afb7c)

```
server {
    listen       0.0.0.0:80;
    server_name localhost;

    ## root /var/www/html;
    root html;

    try_files $uri @proxy;

    location @proxy {
        proxy_pass http://registry.npmmirror.com;
    }
}
```
