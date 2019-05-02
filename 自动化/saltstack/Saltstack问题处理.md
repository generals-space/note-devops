# Saltstack问题处理

## 1.

参考文章

1. [菜鸟玩云计算之廿二: saltstack 配置](http://blog.csdn.net/ubuntu64fan/article/details/45057355)

```
2017-06-22 21:24:40,847 [salt.crypt][CRITICAL][1869] The Salt Master server's public key did not authenticate!
The master may need to be updated if it is a version of Salt lower than 2016.11.5, or
If you are confident that you are connecting to a valid Salt Master, then remove the master public key and restart the Salt Minion.
The master public key can be found at:
/etc/salt/pki/minion/minion_master.pub
2017-06-22 21:24:40,849 [salt.minion][ERROR   ][1869] Error while bringing up minion for multi-master. Is master at 192.168.174.53 responding?
```

**情景描述**

minion服务启动成功, 已通过master的key验证, 但是master对minion的指令得不到回复, 显示如下.

```
[root@192-168-174-53 ~]# salt '*' test.ping
S192-168-174-85:
    Minion did not return. [No response]
```

查看minion日志会发现上述`CRITICAL`错误, 显示多个master? 可明明我配置文件里只写了一个master地址啊.

**原因分析**

与ssh服务的`known_hosts`类似, minion服务与master建立认证关系后会缓存master的公钥. 如果之前部署过minion服务, 而新的master又不是同一个时, 就会出现冲突, 于是认证失败.

**解决方法**

删除minion节点的`/etc/salt/pki/minion/minion_master.pub`即可, 无需重启minion或master. master再次下发指令时会重新生成这个文件.

## 2.

参考文章

1. [saltstack报错：The Salt Master has rejected this minion's public key!](http://outofmemory.cn/code-snippet/33962/saltstack-The-Salt-Master-has-rejected-this-minion-s-public-key)

```
2017-07-24 13:52:28,788 [salt.crypt][CRITICAL][373] The Salt Master has rejected this minion's public key!
To repair this issue, delete the public key for this minion on the Salt Master and restart this minion.
Or restart the Salt Master in open mode to clean out the keys. The Salt Minion will now exit.
2017-07-24 13:55:13,356 [salt.crypt][ERROR   ][475] The Salt Master has cached the public key for this node, this salt minion will wait for 10 seconds before attempting to re-authenticate
```

minion服务启动时报上述错误, 启动失败退出.

这个问题是由于minion节点的id有问题导致的, 解决此问题的方法是首先到master上删除saltstack的minion缓存, 文件目录位置在: `/etc/salt/pki/master/minions`， 然后到minion服务器上, 修改minion的配置文件将id设置为正确的值.

再重启minion服务即可.