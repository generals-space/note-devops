# Postgresql命令行应用

## 1. 创建用户, 数据库, 赋予权限

参考文章

[PostgreSQL新手入门](http://www.ruanyifeng.com/blog/2013/12/getting_started_with_postgresql.html)

初次安装后，默认生成一个名为`postgres`的数据库和一个名为`postgres`的数据库用户。使用`su - postgres`切换到`postgres`系统用户下进入pg命令行, 相当于mysql中的root登录.

### 1.1 PostgreSQL控制台

以新建用户`dbuser`和数据库`exampledb`为例。

```
## 以系统用户身份登录同名数据库用户是不需要密码的
$ su - postgres
## 使用psql命令登录PostgreSQL控制台
$ psql
## 创建数据库用户dbuser（刚才创建的是Linux系统用户），并设置密码。注意结尾的分号(有时甚至不需要`with`?)
postgres=# CREATE USER dbuser [WITH] PASSWORD '指定密码'; 
## 创建用户数据库，这里为exampledb，并指定所有者为dbuser。
postgres=# CREATE DATABASE exampledb OWNER dbuser;
## 将exampledb数据库的所有权限都赋予dbuser，否则dbuser只能登录控制台，没有任何数据库操作权限。
postgres=# GRANT ALL PRIVILEGES ON DATABASE exampledb to dbuser;
```

### 1.2 Shell命令行

添加新用户和新数据库，除了在PostgreSQL控制台内，还可以在shell命令行下完成。这是因为PostgreSQL提供了命令行工具`createuser`和`createdb`。还是以新建用户`dbuser`和数据库`exampledb`为例。

```
$ su - postgres
## 创建数据库用户dbuser，并指定其为超级用户。
$ createuser --superuser dbuser
## 登录数据库控制台，设置dbuser用户的密码，完成后退出PostgreSQL控制台。
$ psql
\password dbuser
\q
## 创建数据库exampledb，并指定所有者为dbuser。
$ createdb -O dbuser exampledb
```

### 1.3 登录数据库

添加新用户和新数据库以后，就要以新用户的名义登录数据库，这时使用的是`psql`命令。

```
## 参数含义：-U指定用户，-d指定数据库，-h指定服务器，-p指定端口。
psql -U dbuser -d exampledb -h 127.0.0.1 -p 5432
```

输入上面命令以后，系统会提示输入dbuser用户的密码。输入正确，就可以登录控制台了。

psql命令存在简写形式。如果当前Linux系统用户，同时也是PostgreSQL用户，则可以省略用户名（-U参数的部分）, 且不需要密码。

```
psql exampledb
```

此时，如果PostgreSQL内部还存在与当前系统用户同名的数据库，则连数据库名都可以省略。比如，假定存在一个叫做`dbuser`的数据库，则直接键入psql就可以登录该数据库。

```
$ su - dbuser
$ psql
```

另外，如果要恢复外部数据，可以使用下面的命令。

```
$ psql exampledb < exampledb.sql
```

> 注意: 如果目标数据库属主不为当前用户, 则可能看到这个库, 但选择后查看库中表时为空.