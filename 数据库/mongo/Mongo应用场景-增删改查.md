# Mongo基本应用

参考文章

[MONGODB基本命令用](http://www.cnblogs.com/liyonghui/p/mongodb.html)

mongo中的集合(Collection)对应关系型数据库中的表(Table), 是一组数据实体. 

mongo中的一条数据就是一个json对象, 被称为一篇文档(Document).

可以在不显式创建`Collection`的情况下插入数据, 但其实mongodb还是隐式地创建了一个`Collection`的, 这个Collection与当前数据库同名.

## 1. 数据库操作

`show dbs`可以查看数据库列表, 类似于mysql中的`show databases;`

### 1.1 新建

```
use 数据库名
```

选择一个存在的数据库, 如果指定的数据库不存在, 则创建一个新的数据库.

需要注意的是, `use`命令创建一个新的数据库后, 使用`show dbs`还无法看到, 你需要至少其中插入一个文档才行.

```
> use general
switched to db general
> show dbs
local    0.000GB

> db.general.insert({'name':'general'})
WriteResult({ "nInserted" : 1 })
> show dbs
general  0.000GB
local    0.000GB
```

### 1.2 删除

```
use 数据库名  
db.dropDatabase()
```

将删除当前选中的数据库, 如果未选中任何数据库, 则删除默认的`test`库.

```
> show dbs
general  0.000GB
local    0.000GB
> use general
switched to db general
> db.dropDatabase()
{ "dropped" : "general", "ok" : 1 }
> show dbs
local  0.000GB
```

## 2. 集合(Collection)操作

### 2.1 创建

可以在不显式创建`Collection`的情况下插入数据, 但其实mongodb还是隐式地创建了一个`Collection`的.

```
> use general
switched to db general
> show collections
> db.post.insert({'title':'first post'})
WriteResult({ "nInserted" : 1 })
> show collections
post
> db.post.find()
{ "_id" : ObjectId("5844fc0f8430b77f4b8084e0"), "title" : "first post" }
```

新创建的数据库默认为空, 使用`db.post.insert()`方法可以在当前数据库创建一个名为`post`的collection, 并向其中插入一条数据.

> 还可以创建`general.post`这种带有点号`.`的集合.

### 2.2 删除

与清空不同, 删除是指删除整个collection, 而不是单纯清空collection中的数据而保留collection.

collection的删除操作是对于当前数据库而言的, 所以需要先选中一个数据库.

```
> db.post.drop()
```

## 3. 文档数据操作



### 2.1 查询

#### 2.1.1 键值查询

```
## 查询所有
db.post.find()

## 精确过滤查询
db.post.find({'title': 'first post'})

## 正则过滤, `/pattern/`正好是js中的正则对象, 可以使用各种正则手段.
db.post.find({title:/first/});
{ "_id" : ObjectId("5844fc0f8430b77f4b8084e0"), "title" : "first post" }

## 数值比较逻辑, 可用选项为`$gt`, `$lt`, `$gte`, `$lte`
db.userInfo.find({age: {$gt: 25}});

## 多条件并列查询. 如下示例, 查询年龄大于25, 姓名以ge开头的user.
db.userInfo.find({age:{$gt: 25}, name: /^ge/})

## 查询指定列. 如下示例第一个大括号代表过滤条件, 空代表查询所有. 第二个大括号代表查询的字段, 1表示true, 0表示false. 
## 注意, 如果没有name或age属性也会返回对象, 只是这种对象的name或age字段为空, 又不会显示它的其他字段而已.
db.userInfo.find({}, {name: 1, age: 1})

## 如下示例表示查询所有name字段不为空的对象, 并返回这些对象的name字段.
db.userInfo.find({name:/.+/},{name:1})
{ "_id" : ObjectId("584518fb737718c346c9e755"), "name" : "general" }

```

#### 2.1.2 位置查询

下面两条命令都可以查看当前所在库

```
db
db.getName()
```



### 2.2 删除

```
## 删除指定
db.userInfo.remove({name: 'general'})
## 删除所有, 相当于清空当前collection, 这并不会删除collection本身
db.userInfo.remove({})
```

## 系统数据库操作

### 查看数据库及数据表大小

参考文章

[mongodb 查看数据库和表大小](http://www.jb51.net/article/52517.htm)

查看指定数据库大小时, 首先要选择一个数据库即`use 指定数据库`, 然后执行`db.stats()`. 示例如下.

```
> use test
> db.stats(); 
{ 
  "db" : "test",        //当前数据库 
  "collections" : 3,      //当前数据库多少表 
  "objects" : 4,        //当前数据库所有表多少条数据 
  "avgObjSize" : 51,      //每条数据的平均大小 
  "dataSize" : 204,      //所有数据的总大小 
  "storageSize" : 16384,    //所有数据占的磁盘大小(单位为字节)
  "numExtents" : 3, 
  "indexes" : 1,        //索引数 
  "indexSize" : 8176,     //索引大小 
  "fileSize" : 201326592,   //预分配给数据库的文件大小 
  "nsSizeMB" : 16, 
  "dataFileVersion" : { 
    "major" : 4, 
    "minor" : 5 
  }, 
  "ok" : 1 
} 
```

查看数据表信息类似

```
> use test
> db.posts.stats(); 
{ 
  "ns" : "test.posts", 
  "count" : 1, 
  "size" : 56, 
  "avgObjSize" : 56, 
  "storageSize" : 8192, 
  "numExtents" : 1, 
  "nindexes" : 1, 
  "lastExtentSize" : 8192, 
  "paddingFactor" : 1, 
  "systemFlags" : 1, 
  "userFlags" : 0, 
  "totalIndexSize" : 8176, 
  "indexSizes" : { 
    "_id_" : 8176 
  }, 
  "ok" : 1 
} 
```