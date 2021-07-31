# kibana-索引模式 index pattern

kibana 里要查询日志信息, 必须要先在`Management`标签页中指定索引模式. 可以这么理解, 由于日志文件一般是以日期作为后缀, 比如`nginx-access.2020-09-01.log`, 后面的日期是会变动的, 创建的索引的名称也是不同的. 要在历史日志中查询信息, 必须把同类型的日志放在一起, 所以就有了**索引模式**这个概念.

在创建索引模式的时候, kibana 会自动检测目标索引中的字段, 如果存在时间序列字段, 就会让用户指定为过滤字段.

![](https://gitee.com/generals-space/gitimg/raw/master/2d4bdf4467ff6bc91b560742a97647e6.png)

如果不存在时间序列, 直接创建就可以了.

![](https://gitee.com/generals-space/gitimg/raw/master/d8a289b06c12507b961f732c7ef92151.png)
