# mongo执行rs.initiate报错 - No host described in new configuration 1 for replica set mongoreplset maps to this node

参考文章

1. [errmsg“ : ”No host described in new configuration 1 for replica set rs0 maps to this node", Why I am getting this message?](http://stackoverflow.com/questions/29211285/errmsg-no-host-described-in-new-configuration-1-for-replica-set-rs0-maps-to)

## 问题描述

在一台装有`mongo`客户端的主机A上, 连接"域名"为`mongo1`主机B, 将其初始化为副本集中的节点, 打算之后通过`rs.add()`方法逐步向此副本集群中添加其他节点.

主机A上通过`/etc/hosts`文件标识了`mongo1`为主机B的域名, 使用`mongo mongo1:27017`是可以连接到主机B上的mongo服务的, 但是执行`rs.initiate()`命令时, mongo表示`mongo1`不能被识别成一个合法主机.

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

## 解决方法

在主机B的`/etc/hosts`文件中添加`主机B的IP mongo1`, 使B也能识别`mongo1`就是它本身. 在主机A上重新执行初始化即可成功.
