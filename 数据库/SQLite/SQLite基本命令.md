# SQLite基本命令

参考文章

1. [SQLite 教程 - RUNOOB.COM](http://www.runoob.com/sqlite/sqlite-tutorial.html)

2. [sqlite3 查询数据库表结构](http://blog.csdn.net/yuxiayiji/article/details/8426280)

SQLite版本: sqlite3

系统版本: CentOS7

sqlite太过轻量, 与其他数据库系统相比, 我觉得它更像一个能够比较高效地以文件形式存取数据的引擎. 

## 1. 进行sqlite命令行(建库)

sqlite创建一个数据库的方法就是创建一个文件.

```
$ sqlite3 数据库名
```

然后就可以对此数据库进行增删改查等操作了.

同理, 对一个已经存在的数据库, 也可以通过这条命令打开.

在sqlite命令行中, 提供了一些类似于pg的`\`反斜线简洁命令, 被称为sqlite的**点命令**, 因为这些命令都是以点号`.`开头的. 执行`.help`即可查阅.

```
[root@localhost ~]# sqlite3 
SQLite version 3.7.17 2013-05-20 00:56:22
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> .help
..省略
.databases             List names and files of attached databases
.tables ?TABLE?        List names of tables
                         If TABLE specified, only list tables matching
                         LIKE pattern TABLE.
```

可以看到`.databases`相当于mysql中的`show databases;`, `.tables`相当于mysql中的`show tables`, 这些点命令是不需要以分号结尾的, 但是标准SQL语句还是需要的.

> 关于`.databases`, 并不是说sqlite与mysql那种数据库系统一样是多库系统, 而是可以通过`ATTACH`(SQL命令)加载其他数据库文件中的数据进行查阅, 并不影响当前库本身的内容.

退出sqlite命令行可用`.quit`或`.exit`.

## 2. 表操作及其他行级操作

### 2.1 查看表结构

两种方法

**1**

默认select查询不会打印column名称, 我们需要`.header on`打开这个设置

```
sqlite> .header on
sqlite> select * from auth_permission limit 1;
id|content_type_id|codename|name
1|1|add_logentry|Can add log entry
```

**2**

`.schema`语句的输出有些详细, 连建表语句都输出来了...

```
sqlite> .schema auth_permission
CREATE TABLE "auth_permission" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "content_type_id" integer NOT NULL REFERENCES "django_content_type" ("id"), "codename" varchar(100) NOT NULL, "name" varchar(255) NOT NULL);
CREATE UNIQUE INDEX "auth_permission_content_type_id_codename_01ab375a_uniq" ON "auth_permission" ("content_type_id", "codename");
CREATE INDEX "auth_permission_content_type_id_2f476e4b" ON "auth_permission" ("content_type_id");
```