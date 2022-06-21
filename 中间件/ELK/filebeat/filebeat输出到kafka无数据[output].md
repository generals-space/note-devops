# filebeat输出到kafka无数据[output]

参考文章

1. [filebeat->kafka没反应。](https://elasticsearch.cn/?/question/4332)
    - filebeat 与 kafka 版本兼容性问题

1. kafka域名不通
2. filebeat与kafka版本存在兼容问题
3. 用于追加日志进行测试的文件, 其实并未被filebeat监听到(就是找错文件了, 一般是因为测试的文件比较旧的缘故)
    - 开启debug模式看看filebeat监听了哪些文件, 然后再向其尾部追加数据试试.
