# Postgres应用-数据转换(格式化)函数

参考文章

1. [PostgreSQL学习手册(函数和操作符<二>)](http://www.cnblogs.com/stephen-liu74/archive/2012/05/04/2294643.html)
    - 七、数据类型格式化函数

2. [postgreSQL数据类型转换字符串和数值](https://www.cnblogs.com/doit8791/p/5214251.html)

在看诸多数据转换函数之前, 先来看一下类型标记的用法.

```sql
# select timestamp '2019-01-18';
      timestamp
---------------------
 2019-01-18 00:00:00
(1 row)

# select int '2019-01-18';
ERROR:  invalid input syntax for integer: "2019-01-18"
LINE 1: select int '2019-01-18';
                   ^
# select varchar 2018;
ERROR:  syntax error at or near "2018"
LINE 1: select varchar 2018;
                       ^
# select int '2018';
 int4
------
 2018
(1 row)
```

可以看到, `varchar`, `int`, `timestamp`这种变量类型, 也可以当作转换函数一样使用, 但是后面接的参数必须是字符串类型, 尝试用`varchar 2018`将数值转换为字符串会失败.

------

以上是数据类型转换, postgres还提供了很多格式化和解析的函数, 例如go中的`Sprintf`, 以及很多语言中的时间戳与时间对象及字符串的格式化函数等.

|函数原型|返回类型|描述|示例|
|:-|:-|:-|:-|
|to_char(timestamp, text)|text|把时间戳转换成指定格式的字符串|`to_char(current_timestamp, 'HH12:MI:SS')`|
|to_char(interval, text)|text|把时间间隔转为指定格式的字符串|`to_char(interval '15h 2m 12s', 'HH24:MI:SS')`|
|to_char(int, text)	|text|把整数转换成字符串|`to_char(125, '999')`|
|to_char(double precision, text)|text|把实数/双精度数转换成字符串|`to_char(125.8::real, '999D9')`|
|to_char(numeric, text)|text|把numeric转换成字符串|`to_char(-125.8, '999D99S')`|
|to_date(text, text)|date|把指定格式的字符串转换成日期|`to_date('05 Dec 2000', 'DD Mon YYYY')`|
|to_timestamp(text, text)|timestamp|把指定格式的字符串转换成时间戳|`to_timestamp('05 Dec 2000', 'DD Mon YYYY')`|
|to_timestamp(double)|timestamp|把数字形式的时间戳转换成时间戳对象|`to_timestamp(200120400)`|
|to_number(text, text)|numeric|把字符串转换成数值(可以是浮点数)|`to_number('12,454.8-', '99G999D9S')`(我的天, 第二个参数是)|

> 关于时间格式的模板标记类型(如`HH`, `MM`等)可以见参考文章1.

`to_number()`的第二个参数为**模式参数**, 具体什么模式可以见参考文章2.