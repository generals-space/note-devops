# Mongo应用场景-数据迁移.1.复制与克隆

参考文章

1. [Mongodb2.6 数据库和集合的复制(1)](https://my.oschina.net/u/1449160/blog/261203)

2. [Mongodb数据导出工具mongoexport和导入工具mongoimport介绍](http://chenzhou123520.iteye.com/blog/1641319)

3. [mongodb 数据库操作--备份 还原 导出 导入](http://www.jb51.net/article/52498.htm)

4. [MongoDB整库备份与还原以及单个collection备份、恢复方法](https://www.cnblogs.com/Joans/p/4453938.html)

## 1. 克隆数据库

使用`cloneDatabase()`方法克隆远程到本地同名数据库. 

语法如下, 克隆远程的`mydb`数据库到本地.

```
> use mydb
> db.dropDatabase();
> db.cloneDatabase("192.168.11.52")
```

注意: 

1. `cloneDatabase()`方法只能从远程拉取数据, 不能推送到远程. 
2. 首先要在本地使用`use`命令选择数据库
3. 本地数据库中不能存在与远程数据库同名的集合, 否则克隆会失败, 所以可以使用`dropDatabase()`方法清除当前数据库.
4. `cloneDatabase()`方法的参数为远程主机名, 可以加端口, 如`192.168.11.5:27017`.

如下是本地当前数据库中存在与远程数据库同名的collections时的结果, 远程集合无法覆盖本地集合, 而其他集合部分会成功, 也有可能失败导致克隆不完全, 所以`dropDatabase()`方法还是很有必要的.

```
> db.cloneDatabase('192.168.173.43')
{
	"clonedColls" : [ ],
	"ok" : 0,
	"errmsg" : "collection already exists",
	"code" : 48
}
```

## 2. 克隆集合

使用`cloneCollection()`方法克隆远程指定集合到本地, 并且可以使用过滤条件排队不需要的文档.

语法如下, 克隆远程的`mydb`数据库中名为`bar`的集合指定文档到本地.

```
> use mydb
> db.cloneCollection("192.168.11.52", "bar", {"name" : "tiger"})
> db.bar.find();
{ "_id" : ObjectId("53687ff4f433cf04b788c6d3"), "name" : "tiger" }
```

`cloneCollection()`方法参数:

- from: 远程主机地址, 可加端口
- collection: 目标集合名称. 
- query: 过滤条件, 可以过滤掉不想要的文档, 与普通查询语句的过滤语法相同.

注意:

1. `cloneDatabase()`方法只能从远程拉取数据, 不能推送到远程. 
2. 同样首先需要在本地使用`use`选择数据库, 从远程主机克隆时也是从这个数据库中克隆.
3. 本地不可以存在同名集合, 否则克隆会失败

## 3. 拉取/推送数据

`copyDatabase()`方法可以从远程主机复制数据库到本地.

参数：

- from: 源数据库名称
- to: 目标数据库名称
- srchost: 可选项, 源数据库的主机地址. 如果就是当前主机, 可以忽略该选项
- username: 可选项, 源主机名用户名
- password: 可选项, 源主机名用户名对应密码

复制本地mydb库到newmydb:

```
db.copyDatabase("mydb", "newmydb", "192.168.11.52");
```

注意:

1. 无需使用`use`预告选择数据库, 如果本地不存在指定数据库, 会自行创建.
2. 并不会产生目标数据库的即时快照. 如果在复制过程中在源或目标库发生读写操作, 会导致数据库不一致(未实验).
3. 在操作过程中并不会锁住目标主机, 所以复制过程中可能出现暂时的中断来完成其他操作.
