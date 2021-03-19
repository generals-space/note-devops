# es接口使用.3._xpack用户管理

参考文章

1. [ElasticSearch _xpack用户管理](https://www.cnblogs.com/shaosks/p/7681865.html)
    - 禁用/启用用户
2. [基于x-pack的ES用户管理（认证）](https://www.cnblogs.com/wangzhen3798/p/13307229.html)
3. [Elasticsearch学习笔记（12）](https://www.jianshu.com/p/08adafb2bdfd)

查看所有用户

```
GET /_xpack/security/user
```

查看指定用户信息

```
GET /_xpack/security/user/my_user
```

修改密码

```
curl -XPOST -u elastic:changeme -H 'Content-Type: application/json' -d '{"password":"123456"}' http://127.0.0.1:9200/_xpack/security/user/elastic/_password
```
