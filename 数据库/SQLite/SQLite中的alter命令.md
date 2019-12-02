# SQLite中的alter命令

参考文章

1. [sqlite3 alter table](https://blog.csdn.net/majiakun1/article/details/46530111)

2. [SQLite Alter 命令](http://www.runoob.com/sqlite/sqlite-alter-command.html)

sqlite3 alter table只支持两个

1. 重命名表名

```sql
alter table tableName rename to  newTableName;
```

2. 新增列名(这里只能添加 check 和 default约束)

```sql
alter table tableName add column columnName integer(类型);
```

...没错, 不能重命名列名, 也不能删除列.

我想把表中的`order`列重命名为`order_num`, 因为`order`是大多数数据库的保留字段, 每次操作都要特殊处理ta, 很烦.

```sql
sqlite> alter table book_chapters rename column `order` to "order_num";
Error: near "column": syntax error
sqlite> alter table book_chapters rename column "order" to "order_num";
Error: near "column": syntax error
```

那么如何重命名列名? 那就新增一个列, 然后把源列的数据拷贝到新列...

```
sqlite> alter table book_chapters add column order_num bigint;
sqlite> .sche book_chapters
CREATE TABLE "book_chapters" ("id" integer primary key autoincrement,"created_at" datetime,"updated_at" datetime,"book_id" bigint,"order" bigint,"title" varchar(100),"summary" varchar(200),"enable" bool , order_num bigint);
sqlite> update book_chapters set order_num = `order`;
```