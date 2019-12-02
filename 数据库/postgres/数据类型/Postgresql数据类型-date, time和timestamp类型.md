# Postgresql数据类型-date, time和timestamp类型

除了常规的`timestamp`时间类型, 也就是普遍意义上的时间对象, postgres还提供了`date`和`time`两种类型, 前者只表示日期, 后者只表示时间.

```sql
postgres=# select date '2019-01-17';
    date
------------
 2019-01-17
(1 row)
postgres=# select date '2019/01/17';
    date
------------
 2019-01-17
(1 row)
postgres=# select date '20190117';
    date
------------
 2019-01-17
(1 row)
postgres=# select date '01-17-2019';
    date
------------
 2019-01-17
(1 row)
postgres=# select date '01/17/2019';
    date
------------
 2019-01-17
(1 row)
```

> 这个`date`转换函数还真是蛮智能的.

`time`这个就不那么智能了, 毕竟`time`对象的表现形式挺单一的.