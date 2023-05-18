参考文章

1. [学习ElasticSearch遇到的问题及解决办法](https://blog.csdn.net/bronzehammer/article/details/96888627)
2. [java8安装/elasticsearch安装及运行失败原因分析](https://www.cnblogs.com/satuer/p/9636643.html)
    - 这就是我遇到的场景.

```log
[elasticsearch@localhost ~]$ elasticsearch
Error: Could not find or load main class org.elasticsearch.tools.java_version_checker.JavaVersionChecker
Caused by: java.lang.ClassNotFoundException: org.elasticsearch.tools.java_version_checker.JavaVersionChecker
```

这种情况基本就是 elasticseasch 目录有权限问题, 我遇到的与参考文章2中完全一致, 且原因是 lib 目录的实际属主是 root(用了软链接, 单纯改软链接的属主是无效的)...
