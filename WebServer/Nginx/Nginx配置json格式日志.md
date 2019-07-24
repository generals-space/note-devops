# Nginx配置json格式日志

参考文章

1. [logstash收集nginx访问日志](https://www.cnblogs.com/Dev0ps/p/9313418.html)

```
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    log_format json '{"@timestamp":"$time_iso8601",'
                     '"@version":"1",'
                     '"client":"$remote_addr",'
                     '"url":"$uri",'
                     '"status":"$status",'
                     '"domain":"$host",'
                     '"host":"$server_addr",'
                     '"size":$body_bytes_sent,'
                     '"responsetime":$request_time,'
                     '"referer": "$http_referer",'
                     '"ua": "$http_user_agent"'
                    '}';
    ...

    server {
        listen       80 default_server;
        root         /usr/share/nginx/html;
 
        include /etc/nginx/default.d/*.conf;
        access_log  /var/log/nginx/access_json.log  json;
 
        location / {
        }
    }
}
```
