# Saltstack部署安装

参考文章

1. [Saltstack 安装部署](http://blog.csdn.net/xiaocao12/article/details/51669236)

centos: 6

saltstack: 2.el6

```
$ yum install salt* -y
$ yum install python-halite
```

Saltstack基于C/S架构，服务端master和客户端minions.

> 注: halite为saltstack的web UI控制台

客户端启动minion, 服务端启动master.

启动后, minion会主动连接master, 所以我们需要事先为minion设置master的地址. 编辑`/etc/salt/minion`, 修改master字段.

```
master: master地址
master_port: master端口
```

> 注意: 键名与键值之间冒号后面有一个空格, 貌似如果没有空格会报错...不过没试过

```
$ service salt-minion start
```

master不需要做修改, 直接启动即可.

```
$ service salt-master start
```

每个minion在安装时都会生成一个`minion_id`, master需要管理员手动确认是否信任, 只有可信任的主机才会交由master统一管理.

最迟10秒, 在master上执行如下命令, 你可以看到有minion主机主动连接的认证信息.

```
$ salt-key -L
Accepted Keys:
Denied Keys:
Unaccepted Keys:
5b27eea50e73
Rejected Keys:
```

其中`Unaccepted Keys`下就是等待认证的minion的id, 这个值存放在`/etc/salt/minion_id`文件中. 如果确认, 使用如下命令添加.

```
$ salt-key -A
$ salt-key -L
Accepted Keys:
5b27eea50e73
Denied Keys:
Unaccepted Keys:
Rejected Keys:
```

如果对客户端信任，可以让master自动接受请求，在master端`/etc/salt/master`配置`auto_accept`字段.

```
auto_accept: True
```

好了, 现在测试一下客户端状态.

```
$ salt '*' test.ping
5b27eea50e73:
    True
```

`True`表示目标主机可连接.

## 2. 常用命令

```
salt '*' cmd.run "ab -n 10 -c 2 http://www.google.com/"
salt '*' cmd.run "nginx -v"
```