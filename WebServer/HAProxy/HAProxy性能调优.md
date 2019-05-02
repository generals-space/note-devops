# HAProxy性能调优


```
global
    ...
    maxconn 4096
    ...
```
![](http://img.generals.com/6d0a912b0cb482948024654cdc2663cc.png)

在`global`块中设置这个值后, 所有的块连接数默认都是4096, 并且默认后端服务器池的连接数是前端的1/10, 见图中红框.

在`listen`块中设置这个值, 则对应的前端(frontend)与后端(backend)都会变化, 并且维持`10:1`的比例.

在`frontend`块中设置这个值, 则只会在对应前端会发生变化, 但是引用的后端不变;

同样, 在`backend`块中设置时, 只能在某一个server字段的后端服务器单独设置, 也只会影响目标server, 如下

```
server callback_server1 127.0.0.1:8080 maxconn 10240 cookie 1 check inter 1500 rise 3 fall 3 weight 1
```