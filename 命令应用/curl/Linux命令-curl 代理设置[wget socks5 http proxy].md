# Linux命令-curl 代理设置[wget socks5 http proxy]

普通的http代理

```
curl -x 127.0.0.1:3128 www.google.com
```

socks5代理

```
curl --socks5 127.0.0.1:1080 www.google.com
```

使用wget达到同样的效果

```
wget -Y on -e 'http_proxy=http://10.10.10.10:10' 'www.google.com'
```

- `-Y`: 是否使用代理; 
- `-e`: 执行命令;

> `wget`只有http代理, 不能直接使用`socks`代理.
