
## 语句规范

SQL语句中的字符串用单引号, 数据库名, 表名, 字段名等用反引号表示

在MySQL5.7.18中实验如下, 

```
mysql> create table `test`(desc varchar(255));
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'desc varchar(255))' at line 1
mysql> create table `test`('desc' varchar(255));
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''desc' varchar(255))' at line 1
mysql> create table `test`(`desc` varchar(255));
Query OK, 0 rows affected (0.06 sec)

mysql> 

```

可以看到, desc是系统保留字, 使用单引号也不能使用, 

创建数据库并指定字符集

```
CREATE DATABASE `test2` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci
```
