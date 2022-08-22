# ingest pipeline预处理.2.script脚本

参考文章

1. [Elasticsearch Pipeline 详解](https://my.oschina.net/u/4072296/blog/3073345)
    - 已失效
2. [Elasticsearch Pipeline 详解](https://blog.csdn.net/lijingjingchn/article/details/103068901)
    - 参考文章1的转载文章
    - `ingest`预处理功能
    - es 5.x 内置了部分 logstash 功能, 即 ingest. 通过`node.ingest: true`选项开启(默认为`true`)
    - 在`es`中创建`pipeline`的方法
    - `Simulate Pipeline API`调试接口
    - ES 内置的`Process`类型及使用示例
3. [如何在 Elasticsearch 中使用 pipeline API 来对事件进行处理](https://blog.csdn.net/UbuntuTouch/article/details/99702199)
4. [Elasticsearch教程(30) pipeline处理 painless script脚本详细总结 查询更新案例](https://blog.csdn.net/winterking3/article/details/114033906)
    - ES pipeline 中 script processor 的使用方法.

## script脚本

processor提供了一些功能, 除了之前提到的的`set`, 还有`remove`, `split`等, 可以实现一些简单的文本处理. 

但是如果处理工作比较复杂, 比如进行逻辑判断, 按数组下标切分字符串, 时间格式转换等功能, 还是需要高级语言支持, `script processor`就提供了这样的功能.

```json
POST _ingest/pipeline/_simulate
{
    "pipeline" : {
        "processors": [
            {
                "script" : {
                    "lang": "painless",
                    "source": """
                        try {
                            ctx.foo = "bar";
                            ctx.xxx = ctx.title;
                            ctx.remove('read_count');
                        } catch (Exception e) {

                        }
                    """
                }
            }
        ]
    },
    "docs": [
        {
            "_index": "article",
            "_id": "id",
            "_source": {
                "title": "my first blog",
                "author": "general",
                "content": "hello world!",
                "read_count": 22,
                "create_at": "2021-07-30 12:00:00"
            }
        }
    ]
}
```

在上面的`script`块中, 我们新增了一个`foo`字段, 并通过`ctx.`获取到了上下文消息体中的字段值, 同时移除了`read_count`字段, 效果如下:

![](https://gitee.com/generals-space/gitimg/raw/master/e6cabb0205959241638895ca2b97b8f1.png)

这就是 pipeline 的能力, 在实际场景中, filebeat/logstash 一般会将日志内容整行发送给 ES, 如下

```
[2020-11-02T16:04:30,280][DEBUG][o.e.x.s.a.e.ReservedRealm] [esc-master-0] user [my_admin] not found in cache for realm [reserved], proceeding with normal authentication
```

而我们需要对每条消息体进行切分, 找出哪部分是日期, 哪部分是日志级别, 哪部分是消息体正文, 然后按照一定的格式写入到索引中. 

这里切分字符串与赋值字段的工作, 就是 pipeline 完成的.

## Tips

前文提到了某些场景是按照日期创建独立索引的, 但是本篇文章中, logstash写入到ES的配置指定的是`pipeline`而不是`index`字段, 这种情况该怎么实现呢?

我们可以在`script`块中添加如下语句, 修改消息体中的`_index`字段, 这样在最终写入的时候, ES会自动创建索引的.

```java
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); 
    long millis = sdf.parse(ctx.create_at).getTime(); 
    sdf = new SimpleDateFormat('yyyy_MM_dd'); 
    ctx._index = ctx._index + '_' + sdf.format(new Date(millis)); 
```

> 注意: 上面是以`ctx.create_at`中的时间为准决定索引时间的, 而不是按照ES自身的当前时间, 因为需要打考虑到日志生成到采集, 传输, 以及ES自身处理的耗时, 使用ES自身的时间是不合适的.

![](https://gitee.com/generals-space/gitimg/raw/master/2809db6a70fc8979301980437a03c001.png)
