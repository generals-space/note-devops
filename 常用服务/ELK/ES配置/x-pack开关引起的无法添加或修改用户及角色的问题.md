# x-pack开关引起的无法添加或修改用户及角色的问题

<!link!>: {A2792681-C483-4D35-A3C4-4B6A4631082D}

参考文章

1. [X-Pack role cannot be created or modified](https://discuss.elastic.co/t/x-pack-role-cannot-be-created-or-modified/93670/6)

ES: 5.5.0

## 场景描述

某天用于业务的 es 集群的`elastic`超级用户的密码被修改了(不知道新的密码是啥), 同时给业务侧使用的`developer`普通用户也无法正常使用了.

当时对于 5.x 版本的 es 集群重置超级管理员账户的操作失败了(未重启节点导致本地账户无法正常访问), 为了不防碍业务侧的正常使用, 只能决定临时将 xpack 认证关闭.

修改各节点的配置文件中`xpack.security.enabled`字段为`false`, 然后重启所有节点.

> 应该可以将各节点全部同时重启, 不需要一个一个重启???. 因为配置文件修改, 相当于各节点的认证机制都不一致了, 不如一次性重启完成.

后来经过1天的测试, 验证了 5.x 版本 es 集群通过本地管理员账户修改`elastic`用户密码的功能, 于是着手尝试恢复该 es 集群的 xpack 认证, 然后将 `elastic`用户的密码重置.

恢复 xpack 配置后, 再次重启集群, 然后在 master-0 节点上使用`users`命令创建本地账户, 这一步是成功的. 但是通过本地账户修改`elastic`用户的密码时却出现了问题.

![](https://gitee.com/generals-space/gitimg/raw/master/649bc82aca9d7c16c26bc5a810e0f582.jpg)

> `my_admin:my_admin`是本地账户的名称及密码.

```json
    "type": "illegal_state_exception",
    "reason": "password cannot be changed as user service cannot write until template and mappings are up to date"
```

不过`my_admin`这个账户的权限还是有的.

![](https://gitee.com/generals-space/gitimg/raw/master/da7fd13be74698a108c71626c5a5025e.jpg)

也能通过这个用户登录 kibana, 获得超级管理员的权限(kibana连接的地址要配到 master-0 节点, 其他节点没有`my_admin`账户).

不过`developer`这个普通用户却可以正常使用了, 所以就暂时先保留了下来. 不过第二天业务侧反应`developer`又不正常了, 没办法, 只得再次将 xpack 认证关闭了.

> x-pack 的关闭 -> 开启, 不影响 es 中已经存在的用户配置, 开启后仍然可以使用.

![](https://gitee.com/generals-space/gitimg/raw/master/0f237c399b6ef7565e7163c60763658f.jpg)

## 

但是我在尝试重现上述问题时, 并未成功. 为了完全模拟该场景, 我还试着在关闭 xpack 前先修改`elastic`的密码, 引起了`kibana`的错误, 但是仍未能重现.

最初是怀疑是数据量的问题, 因为我的实验集群只有默认的4条索引. 但是后来又找了一个没在用的测试集群, 但也没重现, 密码也改成功了...

按照参考文章1的说法, 当关闭 xpack, 再开启之前, 需要先把`.security`索引删除(类似于遗留数据), 由于`.security`中存储着`elastic`内置用户及`developer`普通用户等所有信息, 删除之后再次启用 xpack, 将会重建`elastic`等内置用户, 只不过为业务侧创建的`developer`等普通用户需要再重建了.

我们没办法修改目标集群中`elastic`用户的密码, 只好用测试集群验证一下删除`.security`会有产生严重的影响, 验证通过后就在上述集群中进行操作, 所幸成功了, 问题解决.
