# Redis-expire设置过期时间

参考文章

1. [Redis设置Key的过期时间 – EXPIRE命令](http://www.redisfans.com/?p=68)

在redis中设置键值时默认不会有失效时间的限制, 也就是说, 永不失效(未能持久化到硬盘上而重启实例造成的数据丢失不算). 

我们需要手动为目标键设置失效时间. 方法是

`EXPIRE key seconds`: 为给定 key 设置生存时间, 当 key 过期时(生存时间为 0 ), 它会被自动删除. 

在 Redis 中, 带有生存时间的 key 被称为**易失的**(volatile). 

`ttl key`: 查看目标key的生存时间. 如果未设置则返回-1, 如果目标key不存在则返回-2.

生存时间可以通过使用`del`命令来删除整个key来移除, 或者被`set`命令覆写(overwrite), 这意味着, **如果一个命令只是修改(alter)一个带生存时间的 key 的值而不是用一个新的 key 值来代替(replace)它的话, 那么生存时间不会被改变**. 

比如说, 对一个 key 执行 INCR 命令, 对一个列表进行 LPUSH 命令, 或者对一个哈希表执行 HSET 命令, 这类操作都不会修改 key 本身的生存时间. 

另一方面, 如果使用`RENAME`对一个 key 进行改名, 那么改名后的 key 的生存时间和改名前一样. 

`RENAME`命令的另一种可能是, 尝试将一个带生存时间的 key 改名成另一个带生存时间的`another_key` , 这时旧的`another_key`(以及它的生存时间)会被删除, 然后旧的 key 会改名为`another_key` , 因此, 新的 `another_key`的生存时间也和原本的key一样. 

使用`PERSIST`命令可以在不删除 key 的情况下, 移除 key 的生存时间, 让 key 重新成为一个『持久的』(persistent) key. 

可以对一个已经带有生存时间的 key 执行 EXPIRE 命令, 新指定的生存时间会取代旧的生存时间. 
