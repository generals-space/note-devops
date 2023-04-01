# filebeat-registry文件

参考文章

1. [Filebeat的Registry文件解读](https://www.cnblogs.com/37Y37/p/10623370.html)
2. [filebeat收集日志常见问题](https://blog.51cto.com/cuidehua/2130264)
    - 如果日志文件重命名，是否会重新收集该文件中的内容?
    -  答案是"否", 收集日志是通过文件的inode的，linux中重名名，只是改变了文件名，文件在磁盘的存储位置即inode并未改变。
    - 第一次安装filebeat的时候，文件的读取是否是把文件全部一次性的收集还是收集新增的呢？
    - 默认是全部收集，不过可以通过参数`tail_files: true`进行调整，以免一次读取了很多不需要的日志。

