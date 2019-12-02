# Postgres-判断字符串关系(包含和包含于)

参考文章

1. [关于SQL中的字段“包含”与“包含于”字符串的写法](https://blog.csdn.net/qq_24530769/article/details/75099927)

2. [postgreSQL有没有contains函数？](https://bbs.csdn.net/topics/370204014)

3. [PostgreSQL 判断字符串包含的几种方法](https://blog.csdn.net/luojinbai/article/details/45461837)

参考文章1中提到可以使用`like`关键字判断"包含", 用`instr()`函数判断"包含于", 但`instr()`是mysql的函数, postgres是没有这个函数.

参考文章2中给出了`position()`函数, 参考文章3中又提到了`strpos()`函数, 作用与`position()`相同, 只是参数传入的方法不一样.

1. `position(substring in string)`

```sql
postgres=# select position('aa' in 'abcd');
 position 
----------
        0
(1 row)

postgres=# select position('ab' in 'abcd');
 position 
----------
        1
(1 row)

postgres=# select position('ab' in 'abcdab');
 position 
----------
        1
(1 row)
```

可以看出，如果包含目标字符串，会返回目标字符串笫一次出现的位置，可以根据返回值是否大于0来判断是否包含目标字符串。

2. `strpos(string, substring)`

```sql
postgres=# select strpos('abcd','aa');
 strpos 
--------
      0
(1 row)

postgres=# select strpos('abcd','ab');
 strpos 
--------
      1
(1 row)

postgres=# select strpos('abcdab','ab');
 strpos 
--------
      1
(1 row)
```

由于实际的应用场景中, 比较的双方都是变量, 如果要使用`like`关键字, 需要在子字符串左右两侧加上`%`才能匹配, 不如直接使用`position()`或`strpos()`函数, 判断返回值是否大于0.
