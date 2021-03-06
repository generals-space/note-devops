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

## 概念

### 索引(index)

可以把索引看成关系型数据库的表

ES可以把索引存放在一台机器或者分散在多台服务器上, 每个索引有一或多个分片(shard), 每个分片可以有多个副本(replica).

### 文档(document)

一个文档相当于数据库表中的一行记录

Elasticsearch和MongoDB中的文档类似, 都可以有不同的结构, 但Elasticsearch的文档中, **相同字段必须有相同类型**. 

文档由多个字段组成, 每个字段可能多次出现在一个文档里, 这样的字段叫多值字段(multivalued). 

每个字段的类型, 可以是文本、数值、日期等. 字段类型也可以是复杂类型, 一个字段包含其他子文档或者数组. 

### 文档类型(7.0.0以后被废弃)

在Elasticsearch中, 一个索引对象可以存储很多不同用途的对象. 例如, 一个博客应用程序可以保存文章和评论. 

> 从这个角度来说, 索引应该看作是关系型数据库的库而不是表, 文档才是表, 文档类型即为表字段, 是可以指定类型的.

### 映射(mapping)

所有文档写进索引之前都会先进行分析, 如何将输入的文本分割为词条、哪些词条又会被过滤, 这种行为叫做映射(mapping), 一般由用户自己定义规则. 

我的理解是, 创建`mapping`应该是类型建表的操作, 像在 mysql 中

```sql
create table department(id int primary key auto_increment, department char(50));
```

不过由于 es 毕竟是非关系型的, 文档中包含哪些字段是不确定的, 所以没有办法为这此字段预先进行类型声明, es一般会自动进行分析. 但是如果这些文档中存在某些固定的字段, 我们也可以为这一部分的字段进行字段类型的声明.

### 索引模式(index pattern)

kibana 里要查询日志信息, 必须要先在`Management`标签页中指定索引模式. 可以这么理解, 由于日志文件一般是以日期作为后缀, 比如`nginx-access.2020-09-01.log`, 后面的日期是会变动的, 创建的索引的名称也是不同的. 要在历史日志中查询信息, 必须把同类型的日志放在一起, 所以就有了**索引模式**这个概念.

在创建索引模式的时候, kibana 会自动检测目标索引中的字段, 如果存在时间序列字段, 就会让用户指定为过滤字段.

![](https://gitee.com/generals-space/gitimg/raw/master/2d4bdf4467ff6bc91b560742a97647e6.png)

如果不存在时间序列, 直接创建就可以了.

![](https://gitee.com/generals-space/gitimg/raw/master/d8a289b06c12507b961f732c7ef92151.png)

##

kibana 左侧`Dev Tools`是一个类似 Postman 的工具, 通过 es 的 http 接口做一些操作.

> 由于 es 的索引可以看作是非关系型数据库, 所以操作起来也有点像 mongodb 的命令行.

