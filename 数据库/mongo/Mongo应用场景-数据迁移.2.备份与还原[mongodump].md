# Mongo应用场景-数据迁移.2.备份与还原

参考文章

1. [Mongodb2.6 数据库和集合的复制(1)](https://my.oschina.net/u/1449160/blog/261203)

2. [Mongodb数据导出工具mongoexport和导入工具mongoimport介绍](http://chenzhou123520.iteye.com/blog/1641319)

3. [mongodb 数据库操作--备份 还原 导出 导入](http://www.jb51.net/article/52498.htm)

4. [MongoDB整库备份与还原以及单个collection备份、恢复方法](https://www.cnblogs.com/Joans/p/4453938.html)

## 1. mongodump备份数据库

命令语法

```
mongodump -h IP --port 端口 -u 用户名 -p 密码 -d 数据库 -o 文件存在路径 
```

如果没有用户，可以去掉-u和-p

如果导出本机的数据库，可以去掉-h

如果是默认端口，可以去掉--port

如果想导出所有数据库，可以去掉-d

需要注意的是: **导出的数据不是以单文件形式存在, 所以`-o`参数指定的路径需要是一个目录, 目标mongo实例中的数据库将以目录的形式存放在这里面**.

### 1.1 导出所有数据库

```log
[mongo@192-168-169-75 ~]$ mongodump  -h 127.0.0.1 -o ./mongodatas/
2017-02-06T12:43:57.559+0000	writing log.HCLog to 
...
2017-02-06T12:43:57.569+0000	done dumping guilds.guild_data (1 document)
2017-02-06T12:43:57.584+0000	done dumping upload_data.fs.chunks (62 documents)
[mongo@192-168-169-75 ~]$ ls mongodatas
bs  cheat_history  ew4login  guilds  iap  log  upload_data  user_identify
```

### 1.2 导出指定数据库

```log
[mongo@192-168-169-75 ~]$ mongodump  -h 127.0.0.1  -d guilds  -o ./mongodatas/
2017-02-06T12:43:57.568+0000	writing guilds.guild_data to
2017-02-06T12:43:57.569+0000	done dumping guilds.guild_data (1 document)
```

## 2. mongorestore还原数据库

命令语法

```
mongorestore -h IP --port 端口 -u 用户名 -p 密码 -d 数据库 --drop 文件存在路径 
```

`--drop`的意思是，先删除所有的记录，然后恢复

### 2.1 恢复所有数据库到mongodb中

```
[root@localhost mongodb]# mongorestore mongodatas/  #这里的路径是所有库的备份路径 
```

### 2.2 还原指定的数据库

```
[root@localhost mongodb]# mongorestore -d guild mongodatas/guild/  
 
#将guild还原到目标mongo实例的guild_new数据库中
[root@localhost mongodb]# mongorestore -d guild_new mongodatas/guild/  
```