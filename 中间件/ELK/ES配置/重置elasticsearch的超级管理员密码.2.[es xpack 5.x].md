# 重置elasticsearch的超级管理员密码.2.[es xpack 5.x]

<!key!>: {A2792681-C483-4D35-A3C4-4B6A4631082D}

参考文章

1. [重置elasticsearch的超级管理员密码](https://blog.51cto.com/qiangsh/2342802)
2. [I lost the password that has been changed](https://discuss.elastic.co/t/i-lost-the-password-that-has-been-changed/91867)
3. [Xpack File realm user cant login](https://discuss.elastic.co/t/xpack-file-realm-user-cant-login/90266)
    - 最符合的一种场景
4. [Unable to authenticate user [*****] for REST request [/]](https://discuss.elastic.co/t/unable-to-authenticate-user-for-rest-request/197461)
    - 没什么用
5. [File-based User Authentication](https://www.elastic.co/guide/en/x-pack/5.5/file-realm.html)
   	- 5.x 版本的官方文档
6. [File-based User Authentication](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/file-realm.html)
   	- 7.x 版本的官方文档
7. [Xpack File User is not authorized](https://discuss.elastic.co/t/xpack-file-user-is-not-authorized/75891)
   	- 最终的解决方案.
    - `/_xpack/usage`查看各认证方式的开启情况

ES版本: elasticsearch:5.5.0(镜像)

## 

之前实验过在 7.x 的密码重置, 但是在实验 5.x 的版本时却遇到了很多障碍...

不像 7.x , 5.x 并没有集成 x-pack 插件, 通过`elasticsearch-plugin`安装 x-pack, 会在`plugins`目录下创建`x-pack`子目录, 其中存放的是各种jar包, `bin`目录下也会创建`x-pack`子目录, 其中为`x-pack`提供的一些可执行命令, 同时也会在`$ES_HOME/config`目录下创建`x-pack`子目录.

按照参考文章1中的说法, 执行如下命令

```
cd /usr/share/elasticsearch
./bin/x-pack/users useradd my_admin -p 123456 -r superuser
```

这个步骤会在`/etc/elasticsearch/x-pack/`目录下创建`users`和`users_roles`文件, 存储本地用户和用户与角色的映射表, 内容大致如下


`/etc/elasticsearch/x-pack/users`

```
my_admin:$2a$10$wMqWv5Cdf/IGr1iLdIPWKuGe6DFI.SL7Z5jOC/SLG6PUkMO52nWC.
```

`/etc/elasticsearch/x-pack/users`

```
superuser:my_admin
```

> 需要`/etc/elasticsearch/x-pack/`目录事先存在, 否则执行会出错.

完成后像 7.x 一样尝试修改`elastic`用户的密码, 结果不管怎样都无法成功, 报如下错误

```console
$ curl -u my_admin:123456 localhost:9200/_xpack/security/user
{"error":{"root_cause":[{"type":"security_exception","reason":"unable to authenticate user [my_admin] for REST request [/_xpack/security/user]","header":{"WWW-Authenticate":"Basic realm=\"security\" charset=\"UTF-8\""}}],"type":"security_exception","reason":"unable to authenticate user [my_admin] for REST request [/_xpack/security/user]","header":{"WWW-Authenticate":"Basic realm=\"security\" charset=\"UTF-8\""}},"status":401}
```

这个错误表示, `my_admin`存在, 但是没有办法通过 rest api 的方式认证.

我按照这个错误先去搜索了一下, 发现的确有相似的问题, 见参考文章2, 3, 4, 其中的步骤与参考文章1中的大致相同, 倒是有两处比较可疑.

一是貌似 5.x 版本的本地账户貌似需要所有节点都添加上才可以(7.x 的文档其实也有说, 但实验证明不需要).

> 
As the administrator of the cluster, it is your responsibility to ensure the same users are defined on every node in the cluster. X-Pack security does not deliver any mechanism to guarantee this. --参考文章5

二是貌似要开启 file-based 形式的`realms`的认证方式, 甚至可能需要重启es节点. 尝试在`elasticsearch.yml`中添加如下配置

```yaml
xpack:
  security:
    authc:
      realms:
        file:
          file1:
            order: 0
```

> file 认证和 native 认证都试过了...

于是我就开始了漫长的试错之旅...........太漫长, 不细说了, 反正一直是上面的那个错误.

------

后来我调整了一下 es 的日志级别, 调成 debug, 再使用`my_admin`登录的时候, 发现 es 有如下错误输出

```console
$ d logs -f 08elk-cluster-550-xpack_esc-master-0_1 | grep my_admin
[2020-11-02T16:04:30,280][DEBUG][o.e.x.s.a.e.ReservedRealm] [esc-master-0] user [my_admin] not found in cache for realm [reserved], proceeding with normal authentication
[2020-11-02T16:04:30,281][DEBUG][o.e.x.s.a.f.FileRealm    ] [esc-master-0] user [my_admin] not found in cache for realm [default_file], proceeding with normal authentication
[2020-11-02T16:04:30,281][DEBUG][o.e.x.s.a.e.NativeRealm  ] [esc-master-0] user [my_admin] not found in cache for realm [default_native], proceeding with normal authentication
org.elasticsearch.ElasticsearchSecurityException: unable to authenticate user [my_admin] for REST request [/_xpack/security/user]
	at org.elasticsearch.action.my_admin.cluster.node.stats.TransportNodesStatsAction.nodeOperation(TransportNodesStatsAction.java:77) ~[elasticsearch-5.5.0.jar:5.5.0]
	...省略
	at org.elasticsearch.action.my_admin.cluster.stats.TransportClusterStatsAction.nodeOperation(TransportClusterStatsAction.java:53) ~[elasticsearch-5.5.0.jar:5.5.0]
```

后来是怎么解决的呢...灵机一动, 没有任何预兆, 我尝试把`/etc/elasticsearch/x-pack`拷贝了一份到`/usr/share/elasticsearch/config/x-pack`, 然后再次请求就成功了...

## 正确方法(参考文章7)

docker 容器内的 es x-pack 插件识别的是`/usr/share/elasticsearch/config/x-pack`下的`users`与`users_roles`文件, 但是`bin/x-pack/users`在`useradd`的时候默认在`/etc/elasticsearch/x-pack`下创建, 按照参考文章7中的方法, 直接在`/usr/share/elasticsearch/config/x-pack`中创建即可.

```
CONF_DIR=/usr/share/elasticsearch/config ./bin/x-pack/users useradd my_admin -p 123456 -r superuser
```

注意:

1. `/usr/share/elasticsearch/config/x-pack`需要事先存在, 否则创建将失败
2. ~~创建完成后立刻生效, 无需重启节点~~ 应该是需要重启节点的(只重启一个就可以).
    - 如果是在容器里, 需要通过 volume 将 `config/x-pack`映射出来.
    - 如果是 k8s, 可以通过修改 command, 先启动容器, 创建用户后再启动`elasticsearch`进程, 然后再修改`elastic`用户的密码.
3. 在单个节点上创建本地用户后就可使用, 不必在所有节点上创建.
4. `config/x-pack/{users,users_roles}`文件属主需要与`elasticsearch`进程的启动用户相同, 否则在`elasticsearch`启动时会报错.

## Q&A

### 1. 

```
$ curl -u my_admin:密码 localhost:9200/_cat/health

action [cluster:monitor/health] is unauthorized for user [my_admin]
```

这应该是用`passwd`修改密码不一致了, 将这个用户删除重建吧.

### 2. 

一般来说, 只要没有显式启用其他认证, 比如`ldap`等, 本地认证默认就是可用的. 如果你的集群还可用的话, 比如做实验的时候, 可以通过参考文章7提到的`/_xpack/usage`接口查看一下集群是否支持`file`类型的认证.

```json
$ curl localhost:9200/_xpack/usage
{
  "security": {
    "available": true,
    "enabled": true,
    "realms": {
      "file": {
        "name": [
          "default_file"
        ],
        "available": true,
        "size": [
          1
        ],
        "enabled": true,
        "order": [
          2147483647
        ]
      },
      "ldap": {
        "available": true,
        "enabled": false
      },
    }
  }
}
```

### 3. 

另外, 5.5.0 版本创建本地用户后需要重启`elasticsearch`进程, 需要拥有`x-pack/{users,users_roles}`文件的权限, 所以需要保证`elasticsearch`的启动用户与这两个文件的属主相同, 否则在启动时会报如下错误

![](https://gitee.com/generals-space/gitimg/raw/master/4f86793d158a6dbacce13dd7e2316575.png)
