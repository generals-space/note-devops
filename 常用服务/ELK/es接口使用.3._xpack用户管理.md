# es接口使用.3._xpack用户管理

参考文章

1. [ElasticSearch _xpack用户管理](https://www.cnblogs.com/shaosks/p/7681865.html)

```
curl -XPOST -u elastic:changeme -H 'Content-Type: application/json' -d '{"password":"123456"}' http://127.0.0.1:9200/_xpack/security/user/elastic/_password
```
