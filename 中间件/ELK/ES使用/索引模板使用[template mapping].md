# 索引模板使用[template mapping]

参考文章

1. [ES 10 - 如何使用Elasticsearch的索引模板(index template)](https://www.cnblogs.com/kakatadage/p/9958932.html)
    - 索引模板的增删查
2. [初探 Elasticsearch Index Template（索引模板)](https://www.jianshu.com/p/1f67e4436c37)
    - 索引模板的使用方法: 模板中的`template`字段定义的是该索引模板所应用的索引情况
    - 如`"template": "test-*"`所表示的含义是, 当新建索引时, 所有以`test-`开头的索引都会自动匹配到该索引模板

## 何为模板?

索引模板: 就是把已经创建好的某个索引的参数设置(settings)和索引映射(mapping)保存下来作为模板, 在创建新索引时, 指定要使用的模板名, 就可以直接重用已经定义好的模板中的设置和映射.

比如创建如下索引 

```

```

## 
