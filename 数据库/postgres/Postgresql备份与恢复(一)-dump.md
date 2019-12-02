# Postgresql备份与恢复(一)-dump

参考文章

1. [PostgreSql备份和恢复](http://toplchx.iteye.com/blog/2093821)

2. [PostgreSQL pg_dump&psql 数据的备份与恢复](https://www.cnblogs.com/chjbbs/p/6480687.html)

有三种不同的备份方法: 

1. SQL dump
2. 文件系统级备份（File system level backup）
3. 连续归档（Continuous archiving）

## 备份

dump方法是生成含有SQL命令的文本文件, 当反馈回服务器时, 将顺序执行dump中的命令. postgreSql使用`pg_dump`工具, 基础用例是: 

```
$ pg_dump dbname > outfile
```

注意: 

1. 这个命令可以在任意可以连接数据库的远程机器上运行, 但它需要读表的权限, 所以大多数是用`superuser`用户运行这个命令. 
2. 连接指定的数据库可以使用`-h host`和`-p port`命令选项. 默认的`host`是local host或由PGHOST环境变量指定. 使用`-U`选项设置连接数据库的用户. 
3. `pg_dump`的输出文件可以被更高版本的PostgreSql读取, 它也是唯一可以在不同系统间（比如: 32位->64位）转移数据的方法. 
4. `pg_dump`不阻塞数据库的运行. 

## 恢复

`pg_dump`生成的文件由`psql`读入, 一般命令是: 

```
$ psql dbname < infile
```

当`infile`是由`pg_dump`命令生成的, `dbname`不会被命令创建, 所以在执行`psql`前需要手动创建表. （如: `createdb dbname`）

在执行恢复前, 有适当权限的用户必须存在(虽然没有对应用户数据也能被导入, 但是会报一个`ERROR:  role "原属主名" does not exist`的错误). 但是不管有没有原属主用户存在, 导入后的库的属主都默认是`postgres`, 只能手动修改库属主. ~~除非在导入时手动用`-U`参数指定用户名~~ md这样会报错.

schema, 表级属主等会自动与源库保持一致.

默认情况下, psql遇到SQL错误会继续执行. 你可以使用`ON_ERROR_STOP`变量使`psql`遇到SQL错误时退出, 退出状态码是3. 

```
$ psql --set ON_ERROR_STOP=on dbname < infile  
```
