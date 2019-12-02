# Postgresql数据类型-数组

参考文章

1. [PostgreSQL数组使用](http://blog.csdn.net/luckypeng/article/details/49803805)

2. [PostgreSQL官方文档](https://www.postgresql.org/docs/10/static/functions-array.html)

## 1. 认识

pg中定义的数组是C语言那种强类型约束的数组, 而不是像python, js那种松散约束的`列表`. 可以定义一维，二维甚至更多维度.

不一样的维度元素长度定义在数据库中的实际存储都是一样的，数组元素的长度和类型必须要保持一致，并且以中括号来表示。 

合理的：

array[1,2]            --一维数组 
array[[1,2],[3,5]]  --二维数组 

`'{99,889}'`: 字符串形式表示数组

不合理的: 

`array[[1,2],[3]]`: 元素长度不一致 

`array[[1,2], ['Kenyon','good']]`: 类型不匹配

## 2. 相关操作

### 2.1 创建

创建拥有数组字段的表

```sql
create table tbl_array(id serial primary key, items int[]);
```

### 2.2 插入数据

数组类型的值有两种表示方式, 一种是用字符串形式如`'{1, 2}'`表示一个包含`1`和`2`两个成员的数组, 一种是用内置`array`函数直接实例化一个常规编程语言形式的数组, 如`array([1, 2])`

```sql
insert into tbl_array(items) values('{1,2}');
insert into tbl_array(items) values(array[3,4,5]);
```

```sql
insert into tbl_array(items) values('{5,{6}}');    --错误
insert into tbl_array(items) values('{{5},{6}}');  --正确
```

### 2.3 查询与判断

#### 根据索引

不过貌似**索引值是从1开始的**.

```sql
select * from tbl_array where items[3] = 5;
select items[1], items[2], items[3] from tbl_array where id = 1;
 items | items | items 
-------+-------+-------
     0 |     1 |     2
(1 row)
select unnest(items) from tbl_array where id = 1;
 unnest 
--------
      0
      1
      2
(3 rows)
```

`unnest`函数, 好像只有在sql命令行有用, 程序语言中用处不大...

> `@>`操作符后的参数只能是数组类型, 而不是数组成员.

### 2.4 更新数组字段

#### 数组合并 `||`操作符

```sql
select * from tbl_array where id = 1;
 id |   items   
----+-----------
  1 | {1,2,3} 
(1 row)
update tbl_array set items = items || 7 where id = 1;
select * from tbl_array where id = 1;
 id |   items   
----+-----------
  1 | {1,2,3,7}
(1 row)
update tbl_array set items = items || '{8, 9}' where id = 1;
UPDATE 1
select * from tbl_array where id = 1;
 id |     items     
----+---------------
  1 | {1,2,3,7,8,9}
(1 row)

```

注意: `||`可作数组之间的合并, 也可作数组与单个成员的扩展, 作用类似于js里的`concat`函数. 修改原数据与追加数据的位置可以实现**向后追加**与**向前插入**两种效果.

#### 前方插入 `array_prepend`函数

```sql
update tbl_array set items = array_prepend(0, items) where id = 1;
UPDATE 1
select * from tbl_array where id = 1;
 id |      items      
----+-----------------
  1 | {0,1,2,3,7,8,9}
(1 row)
```

`array_prepend`函数的第1个参数为数组成员, 第2个参数是目标数组, 不能调换. 

其他功能的函数可以查看官方文档, 列举的很详细.

#### 成员替换 `array_replace`函数
