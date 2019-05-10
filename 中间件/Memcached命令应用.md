# Memcached命令应用

参考文章

[linux下memcached的启动/结束的方式](http://www.2cto.com/os/201203/125164.html)

[memcached 常用命令及使用说明](http://www.cnblogs.com/wayne173/p/5652034.html)

```
-p <num>      设置TCP端口号(默认设置为: 11211)
-U <num>      UDP监听端口(默认: 11211, 0 时关闭) 
-l <ip_addr>  绑定地址(默认:所有都允许,无论内外网或者本机更换IP，有安全隐患，若设置为127.0.0.1就只能本机访问)
-c <num>      max simultaneous connections (default: 1024)
-d            以daemon方式运行
-u <username> 绑定使用指定用于运行进程<username>
-m <num>      允许最大内存用量，单位M (默认: 64 MB)
-P <file>     将PID写入文件<file>，这样可以使得后边进行快速进程终止, 需要与-d 一起使用

-v            verbose (print errors/warnings while in event loop)  打印日志, 在非`daemon`情况下才能生效
-vv           very verbose (also print client commands/reponses)  
-vvv          extremely verbose (also print internal state transitions)  
```

命令行连接

`memcached`不像redis那样有专门的客户端, 直接使用`telnet`连接就可以.

```
$ telnet localhost 11211
```

## 常用命令

### set与get

```
set mykey 0 900 3   
abc                 ## 值只能另起一行输入
STORED
get mykey
VALUE mykey 0 3
abc
END
```

`set`/`add`/`replace`命令语法相似.

```
command <key> <flags> <expiration time> <bytes>
<value>

参数说明如下：
command set/add/replace
key     key 用于查找缓存值
flags     可以包括键值对的整型参数，客户机使用它存储关于键值对的额外信息
expiration time     在缓存中保存键值对的时间长度（以秒为单位，0 表示永远）
bytes     在缓存中存储的字节大小
value     存储的值（始终位于第二行）
```

> 注意: `bytes`参数必须与目标值的长度相同(不管是更长还是更短), 不然会出错.

```
set mykey 0 900 3
abcdef
CLIENT_ERROR bad data chunk
ERROR
```

### 查询所有键

`memcached`没有提供像redis的`keys *`这样的命令, 替代方法是使用`stats`的`items`与`cachedump`子命令.

memcached中没有键时, `items`子命令没有任何输出.

```
stats items
END
```

我们手动新增两个键

```
set mykey1 0 900 3
abc
STORED
set mykey2 0 900 3
123
STORED
stats items
STAT items:1:number 2                   ## 这里的`number 2`说明item:1中存在2个键
STAT items:1:age 16
STAT items:1:evicted 0
STAT items:1:evicted_nonzero 0
STAT items:1:evicted_time 0
STAT items:1:outofmemory 0
STAT items:1:tailrepairs 0
STAT items:1:reclaimed 0
STAT items:1:expired_unfetched 0
STAT items:1:evicted_unfetched 0
END
```

> 注意: 这里的item相当于redis中的slot槽, 一个memcached实例中可能有多个item, 示例中只有一个.

然后查询这个item中的所有键

```
stats cachedump 1 2
ITEM mykey2 [3 b; 1495542606 s]
ITEM mykey1 [3 b; 1495542596 s]
END
```

呐, `cachedump`子命令中的`1`表示`item:1`的序号, 2表示查询其中的2个键, 你可以把这个数字改的大一点, 比如1000...

查出来的`ITEM mykey1`就可以用`get`命令操作了.

值得说明的是, memcache中的所有键都只是普通的键值对, 所有值都只是字符串而已, 所以它们都完全平等, 不像redis可以有数据类型.