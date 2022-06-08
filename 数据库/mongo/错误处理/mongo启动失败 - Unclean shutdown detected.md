# mongo启动失败 - Unclean shutdown detected

参考文章

1. [ 修复MongoDB数据库，解决因Unclean Shutdown导致服务不能启动的问题](http://www.itpub.net/thread-1778273-1-1.html)
2. [mongodb意外退出无法启动解决办法（Unclean shutdown detected.）](http://blog.csdn.net/liubo2012/article/details/8565415)

一次系统意外关机后, 启动mongo失败, 在mongo日志中显示如下错误

```
**************
Unclean shutdown detected.
Please visit [url]http://dochub.mongodb.org/core/repair[/url] for recovery instructions.
*************
...
dbexit: really exiting now
```

按照日志中提到的网址中的解决办法(**注意, 只适合`standalone`模式的mongo, 不支持集群模式**).

服务器断电、异常关闭以及直接`killall`命令导致服务终止的情况都可能会被mondodb认为是`unclean shutdown`，因为`unclean shutdown`可能会导致数据不一致性或者数据损坏，所以必须要手动修复后才能继续提供服务。

`unclean shutdown`会在`dbPath`下留下一个非空的`mongod.lock`文件. 下面的命令会检测数据一致性, 并移除`.lock`文件.

```
mongod --dbpath /data/db --repair
```

`--dbpath`选项的值为mongo配置文件中`dbPath`的值.

然后按照正常流程启动即可.

> PS: mongo不适合用暴力的方式去kill，正确的关闭方式为：
>
> 1. `kill -2 PID`或者`kill PID`
> 2. 在admin数据库下(`use admin`)运行命令`db.shutdownServer()`;
