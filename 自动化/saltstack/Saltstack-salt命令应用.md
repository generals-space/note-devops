参考文章

1. [Saltstack快速入门简单汇总](http://www.jb51.net/article/80291.htm)

2. [Saltstack系列3：Saltstack常用模块及API](http://www.cnblogs.com/MacoLee/p/5753640.html)

## 指定多台minion节点

通过`-L`(List)参数, 多个minion用逗号隔开.

```
$ salt -L 'sn192-168-176-54,sn192-168-176-55' test.ping
sn192-168-176-54:
    True
sn192-168-176-55:
    True
```

可以用通配符, 但通配符与多节点(逗号分隔)不能同时使用

```
$ salt 'sn192-168-176*' test.ping
sn192-168-176-55:
    True
sn192-168-176-54:
    True

$ salt -L 'sn192-168-176*,sn192-168-172-46' test.ping
sn192-168-172-46:
    True
```

## 操作多个key, 用逗号分隔

```
$ salt-key -d 192_168_67_42,192_168_67_44
The following keys are going to be deleted:
Accepted Keys:
192_168_67_42
192_168_67_44
Proceed? [N/y] y
Key for minion 192_168_67_42 deleted.
Key for minion 192_168_67_44 deleted.
```

## 查看所有可用模块

```
$ salt '*' sys.list_modules
172.32.100.233:
    - acl
    - aliases
    - alternatives
...省略
```

参考文章2中有详细描述

## 查看模块下所有可用方法

```
$ salt '*' sys.list_functions sys
172.32.100.233:
    - sys.argspec
    - sys.doc
    - sys.list_functions
    - sys.list_modules
...省略
```

------

## salt源码, salt-api, 和salt-xxx命令的对应关系

salt-key应该是wheel模块的别名

salt-run应该是runner模块的别名

命令行中`salt[-xxx]`的格式为`salt [options] <function> [arguments]`

function与arguments可以遵照源码中的参数列表定义. 如官方文档中`salt.runners.jobs.lookup_jid`的函数原型为如下

```py
salt.runners.jobs.lookup_jid(jid, ext_source=None, returned=True, missing=False, display_progress=False)
```

实际使用时可以执行如下命令格式以指定额外参数

```
$ salt-run jobs.lookup_jid 20171102213607265580 missing=True
```
