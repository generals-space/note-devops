# Saltstack可视化界面-halite

参考文章

1. [安装SaltStack和Halite](https://yq.aliyun.com/articles/25860)

2. [安装及配置HALITE](http://docs.saltstack.cn/topics/tutorials/halite.html)

`halite`并且需要`salt-api`模块的支持, 其前端框架用的是`angular`.

安装步骤

下载代码

```
$ git clone https://github.com/saltstack/halite
```

halite依赖`jinja2`模板, 所以在进行下一步之前需要安装.

```
$ pip install jinja2
```

生成`index.html`

```
$ cd halite/halite
$ ./genindex.py -C
```

这里的halite工程没有与web server绑定, 只有单纯的逻辑处理文件, 所以web server需要自己手动下载. 可选的有`cherrypy`, `paste`和`gevent`, 在master配置文件中指定就可以了.

------

修改`/etc/salt/master`文件, 解开如下注释. admin是登录用户名, 下面的应该是权限配置吧.

需要注意的是, admin需要是一个系统用户(但不能是root), 它的密码也正是登录halite时所需的密码.

```
external_auth:
   pam:
     admin:
	 - .*
	 - '@runner'
	 - '@wheel'
```

然后在`/etc/salt/master`尾部添加如下内容.

```
halite:
  level: 'debug'
  server: 'cherrypy'
  host: '0.0.0.0'
  port: '8080'
  cors: False
  tls: False
  static: /root/halite/halite
  app: /root/halite/halite/index.html
```

`static`与`app`路径根据自己halite的存放位置修改.

重启`salt-master`, 然后访问`masterIP:8080`就可以了, 使用admin和它的系统密码登录.