# Redis-xargs+del批量删除

redis并没提供批量删除的有时用户需要批量删除redis中的某些键, 除了写程序, 还可以在shell中完成这种操作(不是redis交互式命令行哦).

批量删除

```
## bash命令行中必须将keys子命令的参数用引号包裹起来
$ redis-cli KEYS 'edu:*' | xargs redis-cli DEL
```

指定操作的数据库(`-n`参数)

```
$ redis-cli -n 12 KEYS 'edu:*' | xargs redis-cli -n 12 DEL
```

------

但是使用同样的方法, 查询指定前缀的键的值时却出现问题

```
$ redis-cli keys 'ios|1|role_info|warrior|*' | xargs redis-cli get
(error) ERR wrong number of arguments for 'get' command
```

解决方法是

```
$ redis-cli keys 'ios|1|role_info|warrior|*' | xargs -i redis-cli get {}
```

原理请参考`xargs`命令的使用方法.
