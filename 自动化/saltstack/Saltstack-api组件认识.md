# Saltstack-api组件认识

参考文章

1. [NETAPI 3种形式 - 官方文档](https://docs.saltstack.com/en/latest/ref/netapi/all/)

2. [配置管理(3) salt-api安装、配置、使用](http://www.xiaomastack.com/2014/11/18/salt-api/)

3. [Salt-API安装配置及使用](http://ju.outofmemory.cn/entry/97116)

4. [SaltStack RESTful API的调用[salt-api]](https://docs.lvrui.io/2016/03/21/SaltStack-RESTful-API%E7%9A%84%E8%B0%83%E7%94%A8-salt-api/)

5. [EXTERNAL AUTHENTICATION SYSTEM salt-api权限配置官方文档](https://docs.saltstack.com/en/latest/topics/eauth/index.html)

6. [通过 RESTful API 调用 SaltStack](http://jaminzhang.github.io/saltstack/SaltStack-API-Config-and-Usage/)

7. [SALT.WHEEL.KEY 官方文档](https://docs.saltstack.com/en/latest/ref/wheel/all/salt.wheel.key.html#salt.wheel.key.list_all)

`salt-api`是saltstack提供的restful形式的api工具集组件. 我觉得它更像是一个完善的web后端, 它本身就实现了身份认证, 并提供了与Shell命令行相同功能的web接口. 一般saltstack的WebUI如`saltpad`, `halite`都是用一个http server加上前端少量前端页面完成的.

若想通过`salt-api`对外提供服务, 需要api组件启动它本身的http server才行. 按照官方文档中的说法, api组件有三种http server容器可选

1. rest_cherrypy

2. rest_tornado

3. rest_wsgi

个人觉得`tornado`还是太重了, `wsgi`功能太少(尤其是貌似只支持127.0.0.1访问), `cherrypy`提供的接口还可以, 网络上的教程大多以此为准. 本文也以`rest_cherrypy`为例.

## 1. 安装与配置

安装与`salt-master`相匹配的`salt-api`

```
$ pip install salt-api==2017.7.1 CherryPy M2Crypto
```

> 要是通过yum装的saltstack, 这些插件也要用yum装, pip装的没用, 而cherrypy在yum源中有两个包, 分别是`python-cherrypy`和`python-cherrypy2`...连介绍都一样, 完全看不出来有什么区别...后者缺了点东西, salt-api启动后无法监听端口, 说是没有`expose`方法. 后来安装的前者, 就可以了.

编辑`/etc/salt/master`文件, 向其中添加如下配置

```
rest_cherrypy:
  port: 8000
  disable_ssl: true
```

注意`disable_ssl`字段, 我们不使用`https`形式, 不然还需要生成证书, 太麻烦. 

然后是配置访问用户权限, salt-api拥有用户验证手段, 也可以定义对外开放的模块. 修改`external_auth`字段如下

```
external_auth:
  pam:                          ## 认证模式，pam指的是用Linux系统本身的用户认证模式
    general:                    ## 这里general是系统用户, 到时需要通过该用户的系统密码完成认证, 不能为root
      - .*                      ## 点号+星号, 表示由api组件开放所有模块的访问
      - '@wheel'                ## 网上还有这种配置, 意思是开放wheel模块下所有方法的权限, 貌似要开放key查询权限必须加上这一条
      ## - '@runner'
```

注意: wheel与.*貌似不重合, 这些都要打开才行, 不然通过salt-api获取key信息时有可能出现`HTTP Error 401: Unauthorized`的问题. 我觉得的runner同理.

参考文章4中详细描述了权限配置部分, 参考文章5中是官方文档中的介绍, 包括用户组, 通配符等, 这里不展开讨论. 

重启master服务, 启动api组件, `salt-api`进程将监听`8000`端口.

## 2. RESTFul API使用

首先要登录, 这样可以得到一个token, 在接下来的12个小时里, 这个token可以作为身份认证的标识. 过期时间可以在master配置文件里的`token_expire`字段中配置

curl -k http://172.32.100.232:8000/login -H "Accept: application/x-yaml" -d username='general' -d password=general系统用户的密码 -d eauth='pam'

下面功能类似于`salt '*' cmd.run ifconfig`

curl -k http://172.32.100.232:8000 -H "Accept: application/x-yaml" -H "X-Auth-Token: ca1e83b9ca3817d8333bd4054892bf3ac1b90b73" -d client='local' -d tgt='*' -d fun='cmd.run' -d arg='ifconfig'

其中

- `client`: 这个参数是最让我纠结的, 目前见过有3个可选值: `local`, `local_async`和`wheel`. 尤其因为网上的教程大多以获取key列表为例, 用到的`@wheel`模块真让人傻傻分不清楚. 猜测`local`与`local_async`作用完全相同, 只不过后者为异步执行. 能操作大部分模块如`grains`, `runner`什么的. 而`wheel`比较特殊, 它可以看作是`salt-key`命令的封装, 同时还包括对master节点的配置功能, 它的使用需要单独拎出来.

- `tgt`: 目标主机, 很好理解

- `fun`: 模块名和方法名, 与命令行中的使用一致就行了

- `arg`: 