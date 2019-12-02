# Mysql建表语句

<!tags!>: <!mysq!> <!主键!> <!自增!> <!外键!>

参考文章

1. [mysql中的外键foreign key](https://www.cnblogs.com/pengyin/p/6375860.html)

2. 

```sql
create table department(id int primary key auto_increment, department char(50));
mysql> create table `user` (id int primary key auto_increment, department_id int not null, name char(20), foreign key(department_id) references department(id));
```

`foreign key`的`references`语句, 貌似`department`后必须要指定被引用的字段, 而不是默认使用它的主键. 否则会报如下错误

```sql
create table `user` (id int primary key auto_increment, department_id int not null, name char(20), foreign key(department_id) references department);
ERROR 1005 (HY000): Can't create table 'mydb.user' (errno: 150)
```

...这一点可不如pg智能.