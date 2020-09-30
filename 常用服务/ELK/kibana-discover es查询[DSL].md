# kibana-discover es查询

参考文章

1. [Kibana 官方文档 Getting Started](https://www.elastic.co/guide/en/kibana/5.5/getting-started.html)
    - 官方提供的测试数据, 进行索引的各种操作, 以熟悉 es 与 kibana 的各种功能.
2. [Visualizing Your Data](https://www.elastic.co/guide/en/kibana/5.5/tutorial-visualizing.html)
    - kibana 可视化配置, 聚合查询

ES版本: 5.5.0

按照参考文章1中官方给出的示例数据集, 尝试ES中的查询操作.

之前对于一些时序数据(比如nginx日志)根本不知道如何下手, 多了时间序列后感觉就不一样了...

直到看到参考文章1中的提供的3个数据集中的其中一个, bank 银行账户数据...

![](https://gitee.com/generals-space/gitimg/raw/master/37258583c103ae828f07721f1f5fe174.png)

这完全就是关系型数据啊...

现在再实验查询就清晰多了, 可以按照参考文章1中指定的步骤进行.

## 1. 简单查询

```
account_number: >900
```

`account_number`为每行记录中的一个字段, 值为整型, 使用ta进行过滤时, 需要在尾部加一个冒号`:`, 而且比较符号与后面的数值之间不能有空格, 否则会报错...

如下, 大于号`>`与数值之间有一个空格, 就报错了.

![](https://gitee.com/generals-space/gitimg/raw/master/4176a06ca2c3740fe1930fd28f850b9a.png)

## 2. 查询结果显示指定列

默认的查询结果是显示整个记录, 所有的字段, 如果想只显示指定的字段, 屏蔽其他无用信息, 可以在左侧`Avaliable Fields`选择要显示的字段.

![](https://gitee.com/generals-space/gitimg/raw/master/9b4787ad309d3a60f5ed72115d7e1feb.png)

> 很像 `kubectl get`使用的`jsonpath`, 或是SQL中的`select(id,name...) from 表名`.
