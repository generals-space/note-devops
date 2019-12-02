# Mongo错误处理

## 1. Unclean shutdown detected

参考文章

[ 修复MongoDB数据库，解决因Unclean Shutdown导致服务不能启动的问题](http://www.itpub.net/thread-1778273-1-1.html)

[mongodb意外退出无法启动解决办法（Unclean shutdown detected.）](http://blog.csdn.net/liubo2012/article/details/8565415)

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
$ mongod --dbpath /data/db --repair
```

`--dbpath`选项的值为mongo配置文件中`dbPath`的值.

然后按照正常流程启动即可.

> PS: mongo不适合用暴力的方式去kill，正确的关闭方式为：

> 1. `kill -2 PID`或者`kill PID`

> 2. 在admin数据库下(`use admin`)运行命令`db.shutdownServer()`;

## 2. No host described in new configuration 1 for replica set mongoreplset maps to this node

参考文章

[errmsg“ : ”No host described in new configuration 1 for replica set rs0 maps to this node", Why I am getting this message?](http://stackoverflow.com/questions/29211285/errmsg-no-host-described-in-new-configuration-1-for-replica-set-rs0-maps-to)

```
mongo mongo1:27017/admin --eval 'rs.initiate({"_id": "mongoreplset", "members": [{"_id": 0, "host": "mongo1:27017"}]});'
MongoDB shell version: 3.2.9
connecting to: mongo1:27017/admin
{
	"ok" : 0,
	"errmsg" : "No host described in new configuration 1 for replica set mongoreplset maps to this node",
	"code" : 93
}
```

问题描述: 

在一台装有`mongo`客户端的主机A上, 连接"域名"为`mongo1`主机B, 将其初始化为副本集中的节点, 打算之后通过`rs.add()`方法逐步向此副本集群中添加其他节点.

主机A上通过`/etc/hosts`文件标识了`mongo1`为主机B的域名, 使用`mongo mongo1:27017`是可以连接到主机B上的mongo服务的, 但是执行`rs.initiate()`命令时, mongo表示`mongo1`不能被识别成一个合法主机.

解决方法:

在主机B的`/etc/hosts`文件中添加`主机B的IP mongo1`, 使B也能识别`mongo1`就是它本身. 在主机A上重新执行初始化即可成功.