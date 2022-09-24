参考文章

1. [ElasticStack系列，第一章](https://blog.csdn.net/LeeDemoOne/article/details/103165610)
    - ElasticStack: ES + Kibana + Logstash + Beats (及ta们各自的作用)
    - 安装部署方法与配置信息
    - ElasticSearch-head 的部署方法
    - ES概念解析: 索引(index), 文档(document), 文档类型, 映射
    - ES 的 RestFul API
2. [ElasticStack系列，第二章](https://blog.csdn.net/LeeDemoOne/article/details/103267437)
3. [ElasticStack系列，第三章](https://blog.csdn.net/LeeDemoOne/article/details/103307275)
4. [ElasticSearch第6节 Kibana 的Dev Tool 增删改查ES](https://www.jianshu.com/p/21007d1011ad)
    - 从 ES 7.0.0 开始, 移除**文档类型(type)**这个概念.
5. [Elasticsearch 7 : 快速上手](https://www.letianbiji.com/elasticsearch/es7-quick-start.html)
    - ES 实例：对应 MySQL 实例中的一个 Database
    - Index 对应 MySQL 中的 Table
    - Document 对应 MySQL 中表的记录
6. [ElasticSearch 字段类型介绍](https://www.jianshu.com/p/bfef6a890b42)
    - 字符串类型有3种: ~~string(废弃)~~, text, keyword
    - `string`在 ES 旧版本中使用较多, 从 5.x 开始不再支持, 由`text`和`keyword`类型替代.

关于es中存储的数据形式, 这里用关系型数据库进行类比, 但是我目前遇到的5.x和7.x在概念理解上有所不同, 所以分别介绍.

|              |      |          |        |        |
| :----------- | :--- | :------- | :----- | :----- |
| ES 5.x       | 索引 | 文档类型 | 文档   | 映射   |
| 关系型数据库 | 库   | 表       | 行记录 | 表结构 |
| ES7.x        |      | 索引     | 文档   | 映射   |

5.x与7.x在概念上的主要区别就在于, 7.x之后将不再支持"文档类型"(当然7.x本身还是支持的), 我们先从7.x开始理解.

## 7.x

索引: 在7.x中, 可以把索引看成关系型数据库的表, 在插入数据之前, 要先创建索引对象;
    - ES可以把索引存放在一台机器或者分散在多台服务器上, 每个索引有一或多个分片(shard), 每个分片可以有多个副本(replica).
文档: 写入索引的每一条数据, 相当于关系型数据库中, 某个表中的一行记录;
映射: 所有文档写入索引之前都会先进行分析, 如何将输入的文本分割为词条、哪些词条又会被过滤, 这种行为叫做该索引的**映射(mapping)**. 
    - 在创建索引时, 可以定义该索引的映射, 类似于在关系型数据库中创建表时, 指定各字段的类型的行为.
    - `create table department(id int primary key auto_increment, department char(50));`

## 5.x

5.x中多了一个"文档类型"的概念, 这个概念的存在让用户可以在一个索引中插入多种结构不同的文档, 通过不同的"文档类型"进行区分. 

这样的话, 将索引比作数据表就不合适了, 因为关系型数据库要求表中所有记录的字段都需要是相同的, 所以我将5.x中的索引类比为了"库(database)"的概念, 文档类型则类比为数据表.

## 实践

假设有一个blog程序, 需要存储两种数据: 文章和评论.

### 5.x

5.x版本中, 可以创建一个索引, 然后分别在两个文档类型下写入数据. 如下

```
PUT /blog

POST /blog/article
{
    "title": "my first blog",
    "author": "general",
    "content": "hello world!",
    "read_count": 22,
    "create_at": "2021-07-30 12:00:00"
}

POST /blog/comment
{
    "user": "小强",
    "content": "大佬牛p",
    "like": 22,
    "create_at": "2021-07-30 12:10:00"
}
```

> 文档类型不需要手动创建.

在查询`blog`索引时, 可以将两种文档类型的数据都显示出来.

![](https://gitee.com/generals-space/gitimg/raw/master/cda2be0344c88cef59b50aad8118534f.png)

> 响应结果中, `_type`字段即为该文档的文档类型.

查询该索引的映射关系时, 也可以发现该索引拥有2个映射属性.

![](https://gitee.com/generals-space/gitimg/raw/master/15c46925835826a42d254ac2541f11da.png)

### 7.x

但是上面的操作在7.x下就行不通了.

```
PUT /blog

POST /blog/article
{
    "title": "my first blog",
    "author": "general",
    "content": "hello world!",
    "read_count": 22,
    "create_at": "2021-07-30 12:00:00"
}
```

在写入`article`数据时, 响应中还会带一句

```
#! Deprecation: [types removal] Specifying types in document index requests is deprecated, use the typeless endpoints instead (/{index}/_doc/{id}, /{index}/_doc, or /{index}/_create/{id}).
```

7.x已经不建议再使用这样的语法了, 不过目前仍然可以使用.

但是在写入`comment`数据时, 就会报错了.

![](https://gitee.com/generals-space/gitimg/raw/master/56ad0fb51f8cfbe6e20e8cdd9e43c01a.png)

这个报错还是很容易理解的, 就是说插入的`comment`数据不符合已经存在的名为`article`的`mapping(表结构)`了.

------

再说一句, 7.x在向索引写入数据时, 已经不推荐上面的格式了, 而是建议如下格式

```
POST /blog/_doc
{
    "title": "my first blog",
    "author": "general",
    "content": "hello world!",
    "read_count": 22,
    "create_at": "2021-07-30 12:00:00"
}
```

这样的话, 写入数据的文档类型就是`_doc`了.

> 需要重建索引, 因为`_doc`仍然会与上面已经存在的`article`文档类型冲突.

