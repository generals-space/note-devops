# MySQL系列-shell命令行操作

## 1. mysql

### 1.1 登录操作

```
$ mysql -h localhost -uroot -p123456
```

如果安装最初始时(mysql的root密码还为空时), 需要在非交互模式执行命令, 就不要加`-p`参数了, 否则会交互时询问密码的(密码为空时`-p`参数不好指定...).

注意> `-p`与密码之间不能有空格, 否则还是会交互式询问密码

### 1.2 shell命令行执行

使用`-e`选项, 在不进入mysql命令行的情况下, 执行sql语句并返回结果

```
$ mysql -u root -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| test               |
+--------------------+
```

## 2. mysqladmin

### 2.1 修改root用户密码

> 注意: mysqladmin不能修改普通用户的密码

命令格式：mysqladmin -uroot -p旧密码 password 新密码

注意> `-p`与密码之间不能有空格, 否则还是会交互式询问密码

最初root为空密码, 可以省略`-p`参数(因为空密码不好指定)

```
$ mysqladmin -u root password 123456
```

现在的密码为123456了, 把它再修改成654321

```
$ mysqladmin -uroot -p123456 password 654321
```

## 3. mysqld_safe

### 3.1 重置root密码

有时候忘记root密码可以使用这个方法重设, 不过需要先停止`mysqld`服务.

```
$ service mysqld stop
Stopping mysqld:                                           [  OK  ]
## 下面这条命令会重新启动mysqld, 但是会跳过验证部分.
$ mysqld_safe --skip-grant-tables&
[1] 32161
$ 161231 08:30:24 mysqld_safe Logging to '/var/log/mysqld.log'.
161231 08:30:24 mysqld_safe Starting mysqld daemon with databases from /var/lib/mysql

## 再次登录就不再需要密码了.
$ mysql -uroot mysql
mysql> UPDATE user SET password=PASSWORD("123456") WHERE user='root';
Query OK, 3 rows affected (0.01 sec)
Rows matched: 3  Changed: 3  Warnings: 0

mysql>  FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)

mysql> quit
Bye
此时可用新密码123456登录
$ mysql -uroot -p123456
```