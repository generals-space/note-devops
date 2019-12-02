# Postgres应用-时间&日期操作

参考文章

1. [PostgreSQL学习手册(函数和操作符<二>)](http://www.cnblogs.com/stephen-liu74/archive/2012/05/04/2294643.html)

## 1. 日期相关的常用系统变量(大小写不敏感)

1. `current_date`: 当前日期(GMT), 如`2019-01-19`.

2. `current_time`: 当前时间(GMT), 如`06:37:44.414209+00`.

3. `current_timestamp`: 当前时间戳对象(GMT), 如`2019-01-19 07:59:22.699173+00`.

4. `current_time(精度)`: 当前时间(GMT), 可以指定精度以决定小数点位数.

5. `current_timestamp(精度)`: 当前时间戳对象(GMT), 同样可以指定精度.

6. `localtime`: 当前时间(当前时区)

7. `localtimestamp`: 当前时间戳(当前时区, 不带时区标记)

8. `localtime(精度)`: 当前时间(当前时区, 可指定精度)

9. `localtimestamp(精度)`: 当前时间戳(当前时区, 可指定精度)

注意, 没有`localdate`变量.

补充: 还有`current_timestamp::[timestamptz|timestamp|date|time]`这种用法, 其中`current_timestamp::date`作用等同于`current_date`, 而`current_timestamp::time`等同于`current_time`.

## 2. 操作符

postgres提供了一种`interval`类型, 表示日期间隔, 类似于golang中的`Duration`, 或者python里的`timedelta`. 基本的计算原则就是, 

1. `date`/`time`/`timestamp` +- 同类型的`date`/`time`/`timestamp`, 得到`interval`变量.

2. `date`/`time`/`timestamp` +/- `interval`, 得到新的`date`/`time`/`timestamp`.

示例如下

|操作符|例子|结果|
|:-:|:-|:-|
|+|`date '2000-01-01' + integer '7'`|`date '2000-01-08'`|
|+|`date '2000-01-01' + interval '1 hour'`|`timestamp '2000-01-01 01:00:00'`|
|+|`date '2000-01-01' + time '03:00'`|`timestamp '2000-01-01 03:00:00'`|
|+|`interval '1 day' + interval '1 hour'`|`interval '1 day 01:00:00'`|
|+|`timestamp '2000-01-01 00:00:00' + interval '2 hours'`|`timestamp '2000-01-01 02:00:00'`|
|+|`time '01:00' + interval '3 hours'`|`time '04:00'`|
|-|`-interval '2 hours'`|`interval '-02:00:00'`|
|-|`date '2001-01-01' - date '2000-01-01'`|`integer '366'`(可以是负值)|
|-|`date '2000-01-10' - integer '9'`|`date '2000-01-01'`|
|-|`date '2000-01-10' - interval '12 hours'`|`timestamp '2000-01-09 12:00:00'`|
|-|`time '05:00' - time '03:00'`|`interval '02:00'`|
|-|`time '05:00' - interval '2 hours'`|`time '03:00'`|
|-|`timestamp '2000-01-10 00:00:00' - interval '12 hours'`|`timestamp '2000-01-09 12:00:00'`|
|-|`interval '1 day' - interval '1 hour'`|`interval '1 day -01:00:00'`(其实就是`interval '23:00'`)|
|-|`timestamp '2000-01-10 00:00:00' - timestamp '2000-01-01 12:00:00'`|`interval '8 days 12:00:00'`|
|*|`interval '1 hour' * double precision '3.5'`|`interval '03:30:00'`|
|/|`interval '1 hour' / double precision '1.5'`|`interval '00:40:00'`|

## 3. 时间函数

1. `now()`: 作用等同于`current_timestamp`变量.

2. `timeofday()`: 返回当前时间(GMT时区), `text`类型, 如`Sat Jan 19 16:14:33.912629 2019 UTC`.

3. `age(timestamp, timestamp)`: 返回`interval`类型结果, 作用是让两者相减, 等同于`timestamp '2000-01-10 00:00:00' - timestamp '2000-01-01 12:00:00'`.

```sql
# select age(timestamp '2000-01-10 00:00:00', timestamp '2000-01-01 12:00:00');
       age
-----------------
 8 days 12:00:00
(1 row)
```

4. `age(timestamp)`: 同样返回`interval`类型, 作用是用当前时间减去参数中指定的时间.

5. `date_part(text, timestamp)`: 从`timestamp`参数中取出相应的部分`text`, 如年, 月, 日等. 示例如下

```sql
# select date_part('year', timestamp '2000-01-10 00:00:00');
 date_part
-----------
      2000
(1 row)
# select date_part('day', timestamp '2000-01-10 00:00:00');
 date_part
-----------
        10
(1 row)
```

6. `extract(text from timestamp)`: 同`date_part`类似, 同样是从`timestamp`变量中获取指定的`text`字段信息. 示例如下

```sql
# select extract(year from timestamp '2000-01-10 00:00:00');
 date_part
-----------
      2000
(1 row)
# select extract(day from timestamp '2000-01-10 00:00:00');
 date_part
-----------
        10
(1 row)
```

7. `date_trunc(text, timestamp)`: 截断成指定的精度, 比如不必精确到秒, 分, 或小时. 示例如下

```sql
# select date_trunc('minute', timestamp '2000-01-10 12:30:45');
     date_trunc
---------------------
 2000-01-10 12:30:00
(1 row)
# select date_trunc('day', timestamp '2000-01-10 12:30:45');
     date_trunc
---------------------
 2000-01-10 00:00:00
(1 row)
```

> `extract`, `date_part`等函数支持的`text`字段类型可以查看参考文章1.