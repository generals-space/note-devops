# 重置elasticsearch的超级管理员密码[es]

参考文章

1. [重置elasticsearch的超级管理员密码](https://blog.51cto.com/qiangsh/2342802)
    1. 停止`elasticsearch`服务; 
    2. 确保你的配置文件中支持本地账户认证支持，如果你使用的是`xpack`的默认配置则无需做特殊修改; 如果你配置了其他认证方式则需要确保配置本地认证方式在`ES_HOME/config/elasticsearch.yml`中; 
    3. 使用命令`ES_HOME/bin/x-pack/users`创建一个基于本地问价认证的超级管理员
    4. 启动`elasticsearch`服务, 通过api重置elastic超级管理员的密码
    5. 校验密码是否重置成功
    6. 确定后续不再使用本地认证则可将`elasticsearch.yml`文件中的本地文件认证方式删除掉
2. [File-based User Authentication](https://www.elastic.co/guide/en/x-pack/5.5/file-realm.html)

## ES版本: elasticsearch:7.2.1(docker镜像)

参考文章1中没有说明ta所用的es版本, 然而我在验证过程中, 发现没有`ES_HOME/bin/x-pack/users`这个文件, 倒是有一个`bin/elasticsearch-users`文件.

登录 es 集群的任意节点, 进入 es 安装目录, 执行如下命令创建本地账户

```
./bin/elasticsearch-users useradd my_admin -p 123456 -r superuser
```

![](https://gitee.com/generals-space/gitimg/raw/master/bce3c45dbbb7e8eebbafbf754d2bd7cf.png)

使用新创建的本地管理员账号修改`elastic`用户密码

```
curl -u my_admin:123456 -XPUT -H 'Content-Type: application/json' -d '{"password":"123456"}' 'http://172.22.253.29:9200/_xpack/security/user/elastic/_password' 
```

![](https://gitee.com/generals-space/gitimg/raw/master/390f97f9de4107ba7319aa9c6c310a06.png)

> 貌似 7.x 不需要重启 es 进程

### ES版本: 5.5.0

使用`elasticsearch-plugins`安装`x-pack`后, `bin`目录下的确出现`x-pack`子目录, 当然, `plugins`目录下也出现了`x-pack`. 前者目录下是可执行文件, 后者则是`jar`包.

> 只要`plugins`下存在`x-pack`的内容, 就可以使用`x-pack`插件, 不需要可执行文件和配置文件. 
