# MySQL备份恢复

参考文章

## 1. 库级备份

### 1. 备份

```
mysqldump -uroot -p密码 源数据库名 > 文件路径
```

如备份mysql同名系统库`mysql`

```
$ mysqldump -uroot -p123456a mysql > ./mysql.sql
```

### 2. 恢复

```
mysql –uroot –p密码 目标数据库名 < .sql文件路径
```

```
$ mysqldump -uroot -p123456a mysql123 < ./mysql.sql
```

注意: 导入指定库时, 需要事先创建目标库, 如上面的`mysql123`