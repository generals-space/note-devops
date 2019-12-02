# PostgreSQL-psql命令行应用

参考文章

1. [postgresql的show databases、show tables、describe table操作](http://blog.csdn.net/u011402596/article/details/38510547)

话说`\xxx`这种语法是pg独有的, 本质上是提供了部分SQL语句的简化版本.

这些简单命令貌似都是无法对数据库造成威胁的操作...一些像删除库删除表什么的就没有简单命令...好贴心啊.

```
ostgres@dev-cmdb-> psql -U sky
psql (9.5.2)
Type "help" for help.

sky=> 
You are now connected to database "sky" as user "sky".
sky=> ls
sky-> 
sky-> 

```

`\l`: 查看所有数据库, 作用同mysql中的`show databases;`, 等价SQL`select datname from pg_database;`

`\c 库名`: 选择数据库, 作用同mysql中的`use 库名`, 等价SQL

`\dt`: 查看当前库中所有表, 作用同mysql中的`show tables;`, 等价SQL`SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';`

`\d 表名`: 查看目标表结构, 及字段类型与约束等详细信息, 作用同mysql中的, `desc 表名`可用SQL`SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '表名';`语句做一个简略替代

`\?`: 查看psql风格的命令帮助列表

`\h`: 查看SQL风格的命令帮助

`\d 表|视图|索引|序列`: 查看表结构

`\i 文件路径`: 执行指定路径的sql