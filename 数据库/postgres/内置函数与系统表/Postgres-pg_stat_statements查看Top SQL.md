# Postgres-pg_stat_statements查看Top SQL

参考文章

1. [PostgreSQL 如何查找TOP SQL (例如IO消耗最高的SQL)](https://yq.aliyun.com/articles/74421)
    - 德哥
    - 只这一篇文章就够了, 给出了查询最耗时, 最耗IO, 最耗共享内存的SQL的示例语句.

由于`pg_stat_statements`只有`userid`列, 无法显示用户名, 如果希望按照sql执行者的用户名来过滤, 需要使用`::`进行类型转换. 如下

```sql
select query from pg_stat_statements where userid::regrole::text = 'lora_backend';
```

`mean_time`: 指定sql运行的平均时间
`total_time`: 同一sql运行的总耗时. 比如在程序中使用`SELECT * FROM "device_types"  WHERE ("id" = $1)`语句进行查询, 虽然`$1`会发生变化, 但是在`pg_stat_statements`表中会被当作同一条记录, 多次执行程序, `total_time`会发生累加.
`calls`: 当前SQL执行的总次数. 可以用来查看执行最多的语句, 以便重点优化.
