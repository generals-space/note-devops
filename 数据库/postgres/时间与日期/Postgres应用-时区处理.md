# Postgres应用-时区处理

参考文章

1. [PostgreSQL date() with timezone](https://stackoverflow.com/questions/11126037/postgresql-date-with-timezone)

2. [Postgres timestamp with timezone](https://stackoverflow.com/questions/25456465/postgres-timestamp-with-timezone)

查看当前时区

```sql
show timezone;
 TimeZone
----------
 UTC
(1 row)
```

视图`pg_timezone_names`保存了所有可供选择的时区.

```sql
select * from pg_timezone_names where abbrev = 'CST';
              name              | abbrev | utc_offset | is_dst
--------------------------------+--------+------------+--------
 Asia/Chongqing                 | CST    | 08:00:00   | f
 Asia/Shanghai                  | CST    | 08:00:00   | f
 Asia/Harbin                    | CST    | 08:00:00   | f
...
```

## 获取当前带指定时区的时间

```sql
# SELECT now() at time zone 'Asia/Shanghai';
# SELECT current_timestamp at time zone 'Asia/Shanghai';
          timezone
----------------------------
 2019-01-22 10:45:09.218967
(1 row)
```

> 任何带有时区的对象都可以加上`at time zone '具体时区'`来得到相应时区的时间表示.

> postgres 9.x貌似已经没有`with time zone`或`without time zone`的说法了, `localtimestamp`就是不带时区的.

## 设置时区

在psql中使用如下语句就可以设置时区

```sql
set time zone 'Asia/Shanghai';
```

不过生效时间只是此次会话, 断开重连后就无效了, 也不会影响其他连接.

需要注意的, 如果在orm连接中执行这样的语句, 如在gorm中调用

```go
db.Exec("set time zone 'Asia/Shanghai';")
```

影响的是此次连接会话中的**所有操作**, 就是说之后所有的方法都会以上海时区来处理. ta的作用可相比于在数据库连接字符串指定时区参数(貌似只有mysql支持在连接字符串中通过`loc`参数指定时区, postgres的话还是手动执行设置时区的操作吧).
