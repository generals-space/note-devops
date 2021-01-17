# IK中文分词器.2.自定义词库

参考文章

1. [Elasticsearch 常用分词器介绍与 ik 分词器自定义词库添加](https://techlog.cn/article/list/10183300)
    - 常用内置分词器功能介绍
    - `IK`中文分词器的分词机制, 安装及使用
    - 自定义分词"小脑斧"
2. [Elasticsearch词库扩充实践](https://blog.csdn.net/ldllovegyh/article/details/82820653)
    - `${es_home}/plugins/ik/config`路径, 与参考文章1不同
3. [Elasticsearch配置IK分词器的远程词库](https://zhuanlan.zhihu.com/p/95873129)
    - 远程词库

ES: 5.5.0

在前文的介绍中我们了解到, `IK`的`ik_smart`智能分词插件有一定的语义解析能力, 但这是针对通用语法而言的. 

对于特殊场景比如专业用语(计算机, 医学), 古诗文, 网络热词, 方言等, 就不那么给力了. 

为了应对多样的场景, 可能需要添加自定义的词库.

> 这一点可以类比一下搜狗输入法, ta们也有更新词库的需要.

举例如下

```json
POST _analyze
{
    "analyzer": "ik_smart",
    "text": "我是一只小脑斧"
}
```

`ik_smart`会将内容切分为如下`token`

[`我`, `一只`, `小脑`, `斧`]

显然, `ik_smart`并不认识"小脑斧"...

## 配置自定义分词库

在集群**所有节点**的`${es_home}/config/analysis-ik/`下创建`custom`目录, 并在`custom`目录中添加`my.dic`文件, 在该文件中可以任意加入自定义分词, 每个分词占用一行.

```
小脑斧
```

编辑完成后, 打开`${es_home}/config/analysis-ik/IKAnalyzer.cfg.xml`添加相应配置:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
    <comment>IK Analyzer 扩展配置</comment>
    <!-- 用户可以在这里配置自己的扩展字典(多个字典可以用分号分隔) -->
    <entry key="ext_dict">custom/my.dic</entry>
    <!-- 用户可以在这里配置自己的扩展停止词字典 -->
    <entry key="ext_stopwords"></entry>
    <!-- 用户可以在这里配置远程扩展字典 -->
    <!--  <entry key="remote_ext_dict">words_location</entry> -->
    <!-- 用户可以在这里配置远程扩展停止词字典-->
    <!--  <entry key="remote_ext_stopwords">words_location</entry> -->
</properties>
```

不过在我的场景中, 这两个文件分别位于`${es_home}/plugins/ik/config/IKAnalyzer.cfg.xml`, 与`${es_home}/plugins/ik/config/custom/my.dic`才有效. 我的插件列表如下

```console
$ elasticsearch-plugins list
ik
```

而且只在ES集群中的一个节点上创建词库, 然后重启即可生效, 无需在所有节点上创建(不过为了高可用, 最好还是在所有节点上创建吧...).
