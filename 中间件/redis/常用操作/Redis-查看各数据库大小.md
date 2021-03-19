# Redis-查看各数据库大小

参考

1. [redis分好库之后怎么才能看每个库的大小呢？](https://segmentfault.com/q/1010000000665987)

redis 貌似没有提供一个可靠的方法获得每个 db 的实际占用, 这主要是因为 redis 本身就没有 db 文件概念, 所有 db 都是混在一个 rdb 文件里面的. 

要想估算 db 的大小, 需要通过 keys * 遍历 db 里所有的 key, 然后用 debug object <key> 来获得 key 的内存占用, serializedlength 就是占用内存的字段长度. 

根据 RDB 格式文档, 可以估算出每个 key 的实际占用为: 

```
key_size = strlen(key) + serializedlength + 7
```

不过这个估算极不靠谱, 因为 redis 可能将 key 做压缩, 此时估算出来的值可能偏大. 

下面的命令可以查看 db0 的大小（key 个数）, 其他的以此类推. 类似于mysql中`select count(*) from 表名`, 不过使用`keys *`也可以得到所有的键, 并且根据序号排列.

```
127.0.0.1:6379> select 0
OK
127.0.0.1:6379> dbsize
(integer) 473
```

或者使用 `info keyspace` 同时得到所有 db 信息. 

```
127.0.0.1:6379> info keyspace
# Keyspace
db0:keys=473,expires=0,avg_ttl=0
db1:keys=3911,expires=3909,avg_ttl=0
```
