
参考文章

1. [Download MySQL Yum Repository](https://dev.mysql.com/downloads/repo/yum/)

2. [CentOS7 安装 Mysql 5.7,密码查看与修改](http://53cto.blog.51cto.com/9899631/1841404)

3. [mac mysql error You must reset your password using ALTER USER statement before executing this statement.](http://www.cnblogs.com/debmzhang/p/5013540.html)

CentOS7默认不再有mysql的yum源, 安装mysql需要下载官方社区版的rpm包才可以. 见参考文章1.

系统版本: CentOS7

mysql版本: 5.7.18 

安装完成后默认root密码不为空, 根据参考文章2中的提示, 临时密码将会输出在日志文件中, 可以用如下方法查看.

`cat /var/log/mysqld.log | grep password`

```
$ cat /var/log/mysqld.log |grep password
2017-07-08T03:26:40.682090Z 1 [Note] A temporary password is generated for root@localhost: ZaYhs*Ckz9qf
```

使用临时密码登录

```
$ mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.7.18

Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

但是这也只是个临时密码而已, 无法进行任何操作.

```
mysql> show databases;
ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
```

参考文章3中有对应的解决方法.

```
ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
mysql> SET PASSWORD = PASSWORD('123456'); 
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements  ## 不能太简单
mysql> SET PASSWORD = PASSWORD('7n%7Zgt{fbyK');
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.02 sec)

mysql> exit
$ mysql -uroot -p
Enter password:                 ## 新密码
...
mysql> 
```

成功.