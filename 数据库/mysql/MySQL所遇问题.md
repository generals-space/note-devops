# MySQL所遇问题

## 1. Ignoring query to other database

问题描述: 命令行下操作数据库, 执行很多指令都会出现这个错误

```sql
mysql> use mysql;
Database changed
mysql> select host, user from user;
Ignoring query to other database
mysql> select host,user from user;
Ignoring query to other database
```

问题分析: 可能是命令行下执行mysql命令没有加`-u`参数的原因

解决办法: 加上`-u`参数重新连接, 一切正常

## 2. MySQL开启远程登陆后, 本地却无法再登陆

开启远程登陆的方法一般为:

```sql
mysql> grant all on 数据库名.表名 to '用户名'@'%';
mysql> flush privileges;
```

而原本'用户名'@‘localhost’即使存在也无法再在本地登陆, 可再次运行:

```sql
mysql> grant all on 数据库名.表名 to '用户名'@'localhost' identified by '密码';
mysql> flush privileges;
```

重新为其赋予本地权限(带上密码)试试看.
