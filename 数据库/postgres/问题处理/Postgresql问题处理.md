# Postgresql问题处理

## 1. 

```
[postgres@localhost data]$ psql
psql: could not connect to server: No such file or directory
	Is the server running locally and accepting
	connections on Unix domain socket "/opt/data/.s.PGSQL.1921"?
```

问题描述:

源码安装postgresql-9.5.4, 安装目录为`/usr/local/pgsql`, 数据目录在`/opt/data`. 使用`postgres`用户启动pg, 之后使用`psql`命令进入pg命令行时, 出现上述错误.

原因分析:

pg在启动时会生成一个`sock`文件, 用做客户端与数据库沟通的途径, 而上面说找不到`/opt/data/.s.PGSQL.1921`文件, 而实际上`/opt/data`目录下确实没有这个文件. 查看pg的配置文件, 发现有名为`unix_socket_directories`的字段, 其默认值为`/tmp`. 查看`/tmp`下的确存在此文件. 很有可能是`sock`文件路径的问题.

解决方法:

修改pg配置文件中`unix_socket_directories`字段, 然后重启pg数据库即可.

或者更简单一点, 如果不想重启数据库, 为`/tmp/.s.PGSQL.1921`文件建立软链接至`/opt/data`目录下即可.

## 2. pg关键字作库/表名的问题

参考文章

1. [postgreSql 中自定义的字段和数据库关键字重名](http://blog.csdn.net/linbilin_/article/details/50774096)

以`user`关键字为例.

```sql
postgres=# create database user;
ERROR:  syntax error at or near "user"
LINE 1: create database user;
                        ^
```

可以看到显示语法错误, 但其实这句SQL没有任何错误.

如果必须要创建以user为名的数据库, 可以通过在`user`上加上双引号包裹.

```sql
postgres=# create database "user";
CREATE DATABASE
```

同理, 删除以关键字命名的库/表时, 名称字符串也要用双引号包裹. 这一点与mysql不同(mysql需要用反斜线包裹)

## 3.

```
postgres=# drop database db_1;
ERROR:  database "db_1" is being accessed by other users
DETAIL:  There is 1 other session using the database.
```

场景描述: 进入psql后, 删除`db_1`库时提示其他用户正在访问无法删除

...`ps -ef | grep psql`发现有两个`psql`进程, 嗯, 可能是之前psql进行没退出就直接把电脑休眠的原因. 把那个被挂起的psql进程kill掉就可以.

网上也有说是其他主机上来连接的会话. 这个就需要重新确认了. 可能通过`netstat -anp | grep pg监听端口`可以查看.

## 4.

```
permission denied for sequence user_id_seq
```

在使用`psycopg2`操作pg时, `insert`操作报上述错误.

原因是在创建了`userA`用户, 创建了`exampledb`数据库并将数据库的属主赋予`userA`后, 又用超级帐户创建该库中的`user`表. 后来发现程序没有此表的权限, 就又删除了这个表, 用普通用户`userA`创建新表, 但再次运行程序就报`permission denied for sequence user_id_seq`. 可能是删除`user`表, 但是`user_id_seq`(自增序列, 不是某一个表字段)没有删除的原因.

解决办法是, 超级用户在此数据库中执行如下语句.

```
grant all on sequence user_id_seq to myuser;
```

参考文章

[Error "permission denied for sequence user_id_seq" when POSTing](https://github.com/begriffs/postgrest/issues/251)