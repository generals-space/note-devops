# es用户名密码设置

## 配置

貌似 es 只接受以环境变量(`ELASTIC_USERNAME`和`ELASTIC_PASSWORD`)的形式配置用户名密码, 在配置文件中写`elastic.usernmae`或是`elastic.password`的话, es 启动会报错.

```
"Caused by: java.lang.IllegalArgumentException: unknown setting [elastic.usernmae] please check that any required plugins are installed, or check the breaking changes documentation for removed settings",
...省略
"Suppressed: java.lang.IllegalArgumentException: unknown setting [elastic.password] please check that any required plugins are installed, or check the breaking changes documentation for removed settings",
```

> 我们的做法是不通过配置文件或环境变量设置密码, 在 es 启动完成后使用默认密码`changeme`修改为指定密码.

## 修改

```
curl -XPUT -u elastic:changeme -d '{ "password" : "your_passwd" }' 'http://localhost:9200/_xpack/security/user/elastic/_password' 
curl -XPUT -u elastic:changeme -H 'Content-Type: application/json' -d '{ "password" : "your_passwd" }' 'http://localhost:9200/_xpack/security/user/elastic/_password' 
```

> 5.x 版本可能需要加`Content-Type: application/json`

