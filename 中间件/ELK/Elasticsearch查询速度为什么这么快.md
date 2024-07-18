# Elasticsearch查询速度为什么这么快

参考文章

1. [Elasticsearch查询速度为什么这么快？](https://zhuanlan.zhihu.com/p/280676094)
2. [ES既是搜索引擎又是数据库？真的有那么全能吗？](https://mp.weixin.qq.com/s?__biz=MzU0OTE4MzYzMw==&mid=2247489360&idx=5&sn=83e57e422d43374a20136834b1824bf5)
    - 算法应该算是数据产品本质的区别，关系型数据库索引算法主要是基于B-Tree， Elasticserach索引算法主要是倒排索引，算法的本质决定了它们的应用边界，擅长的应用领域。

下面是一张表的数据：

| id   | name | age  |
| :--- | :--- | :--- |
| 1    | 张三 | 24   |
| 2    | 张四 | 23   |
| 3    | 李四 | 23   |
| 4    | 李五 | 24   |

在mysql中，主键id建立**b+树索引**，然后通过目录页对应到数据页，然后找到数据。对于传统的增删改查（用id）没有任何问题，速度也很快。

查询非主键的字段如name或者age，则会使用到聚簇索引（面试常会考）因为用到了索引所以速度还是可以的。

但是对于全文检索来说。比如查询"like %张三"。这样是走不到索引的，需要全表扫描, 所以大数据量情况下全表扫描速度非常慢。

但是对于es来说，这就好办多了.

## es采用倒排索引

下面的的索引结构其实就是倒排索引。

name：

| Term | Posting List（文档id集合） |
| :--- | :------------------------- |
| 张三 | 【1】                      |
| 张四 | 【2】                      |
| 李四 | 【3】                      |
| 李五 | 【4】                      |

age：

| Term | Posting List（文档id集合） |
| :--- | :------------------------- |
| 23   | 【2，3】                   |
| 24   | 【1，4】                   |

### Posting List

Elasticsearch会为每个field都建立了一个倒排索引，张三、李四、23、24…这些叫term，而[1,4]就是Posting List。

Posting list就是一个int的数组，存储了所有符合某个term的文档id。

通过posting list这种索引方式似乎可以很快进行查找，比如要找age=24的同学，很快就会找到，id是1，4的同学。

> 倒排索引: 其实就是将文章内容使用分词器打散成各个关键字, 然后通过这些关键字来反向查找其所属的文章.

但是，如果有上千万的记录呢？如果是想通过name来查找呢？所以需要将Term进行排序

### Term Dictionary

Term Dictionary：为了快速找到某个特定的term，将所有的term进行排序。再采用二分查找法查找term, 时间复杂度logN. 看起来，似乎和mysql数据库通过B-Tree的方式类似。而且Elasticsearch直接通过内存查找term，不读磁盘.

但是如果term特别多的话，term dictionary也会很大，将所有的term dictionary都缓存到内存里是不太现实的。

### Term Index

它包含的是term的一些前缀。所以term index 占用的空间只有term的的几十分之一。在内存里可以放更多的term index。缓存所有的term index到内存里是可以的。
Term Index，就像字典里的索引页一样，A开头的有哪些term，分别在哪页，可以理解term index是一颗树.

> 有点像 etcd 里的层次结构, 还可以前缀查找;

从term index查到对应的term dictionary之后，再去磁盘上找term，大大减少了磁盘随机读的次数，查询效率大大提升。
