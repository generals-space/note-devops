# redis-cli-hash类型[hset hget hmset hmget]

参考文章

1. [What is the difference between HSET and HMSET method in redis database](https://stackoverflow.com/questions/15264480/what-is-the-difference-between-hset-and-hmset-method-in-redis-database)

`hset`以前每次只能设置一对k-v, 如果想要同时设置多个, 需要使用`hmset`.

现在`hset`和`hmset`都可以设置多个k-v, `hmset`就显得有点多余了. 官方文档中说, `4.0.0`以后将考虑废弃`hmset`.
