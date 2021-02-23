# Redis设置访问密码

参考文章

1. [redis配置认证密码](http://blog.csdn.net/zyz511919766/article/details/42268219)

## 1. 通过配置文件进行配置

redis默认是没有密码的, 其密码设置在其配置文件中`requirepass`字段, 默认是被注释的.

```
# requirepass foobared
```

解开注释, 并将上面的'foobared'改成你自己的密码, 然后重启redis.

```
requirepass 123456
```

这个时候再次连接redis, 发现可以连接上, 但是执行具体命令时提示操作不允许.

```
redis-cli -h 127.0.0.1 -p 6379  
redis 127.0.0.1:6379>  
redis 127.0.0.1:6379> keys *  
(error) ERR operation not permitted  
redis 127.0.0.1:6379> select 1  
(error) ERR operation not permitted  
redis 127.0.0.1:6379[1]>
```

而尝试用密码登录并执行具体的命令, 可以看到命令成功执行.

```
redis-cli -h 127.0.0.1 -p 6379 -a 123456
redis 127.0.0.1:6379> keys *
(empty list or set)
redis 127.0.0.1:6379[1]> config get requirepass  
1) "requirepass"
2) "123456"
```

## 2. 通过命令行进行配置

```
redis 127.0.0.1:6379> config set requirepass 654321  
OK  
redis 127.0.0.1:6379> config get requirepass  
1) "requirepass"  
2) "654321"
```

无需重启redis.

使用第一步中配置文件中配置的老密码登录redis, 会发现原来的密码已不可用, 也时显示操作被拒绝.

```
redis-cli -h 127.0.0.1 -p 6379 -a 123456  
redis 127.0.0.1:6379> config get requirepass  
(error) ERR operation not permitted
```

使用刚才通过命令行设置的密码登陆, 可以执行响应操作.

```
redis-cli -h 127.0.0.1 -p 6379 -a 654321  
redis 127.0.0.1:6379> config get requirepass  
1) "requirepass"  
2) "654321"
```

尝试重启一下redis, 用新配置的密码登录redis执行操作, 发现新的密码失效, redis重新使用了配置文件中的密码.

-----

除了在登录时通过 -a 参数制定密码外, 还可以登录时不指定密码, 而在执行操作前进行认证. 

```
redis-cli -h 127.0.0.1 -p 6379  
redis 127.0.0.1:6379> config get requirepass  
(error) ERR operation not permitted  
redis 127.0.0.1:6379> auth 123456  
OK  
redis 127.0.0.1:6379> config get requirepass  
1) "requirepass"  
2) "123456"
```

## 3. 集群模式下的密码配置

若master配置了密码, 则slave也要配置相应的密码参数否则无法进行正常复制. slave中配置文件内找到如下行, 移除注释, 修改密码即可

```
#masterauth  master的密码
```
