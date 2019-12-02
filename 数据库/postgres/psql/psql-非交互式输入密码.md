# psql-非交互式输入密码

参考文章

1. [用客户端命令psql连接 PostgreSQL 不输入密码的方法](https://blog.csdn.net/zhu_xun/article/details/23347869)

2. [PostgreSQL 自动输入密码](https://www.cnblogs.com/litmmp/p/5122534.html)

想达到的目的就像下面这样, 可以在脚本写命令, 而不是进入交互式命令行. 其实psql这样做的意义不大, 主要还是在shell脚本里使用`pg_dump`更常用.

```
~ # psql -h 172.16.0.33 -p 6543 -U azure -d azureiotpcs -c 'select id, name from rules;';
              id               |         name          
-------------------------------+-----------------------
 default_Engine_Fuel_Empty     | Engine tank empty
 default_Chiller_Pressure_High | my name is chiller...
 TemperatureSensor_Voltage_Low | 温感电压较低
(3 rows)
```

psql中并没有指定密码的字段, 但是有两种方法可以实现.

## 1. 设置环境变量 PGPASSWORD

`PGPASSWORD`是 PostgreSQL 系统环境变量，在客户端设置这后，那么在客户端连接远端数据库时，将优先使用这个密码。

```
$ export PGPASSWORD=123456
$ psql -h 192.168.8.22 -p 5432 -U postgresql -d my_tbl
psql (9.3.2)
Type "help" for help.
my_tbl=# 
```

> 注意：设置环境变量`PGPASSWORD`，连接数据库不再弹出密码输入提示。 但是从安全性方面考虑，这种方法并不推荐，

## 2. 在客户端设置`.pgpass`密码文件：

通过在用户家目录下创建隐藏文件`.pgpass`，从而避免连接数据库时弹出密码输入提示。

格式为

```
hostname:port:database:username:password
```

示例

```
192.168.1.22:5432:my_tbl:postgresql:123456
```

设置权限

```
chmod 600 .pgpass
```

> win下对应的是`%APPDATA%\postgresql\pgpass.conf`