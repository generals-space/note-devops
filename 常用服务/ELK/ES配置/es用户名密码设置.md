# es用户名密码设置

貌似 es 只接受以环境变量(`ELASTIC_USERNAME`和`ELASTIC_PASSWORD`)的形式配置用户名密码, 在配置文件中写`elastic.usernmae`或是`elastic.password`的话, es 启动会报错.

```
"Caused by: java.lang.IllegalArgumentException: unknown setting [elastic.usernmae] please check that any required plugins are installed, or check the breaking changes documentation for removed settings",
...省略
"Suppressed: java.lang.IllegalArgumentException: unknown setting [elastic.password] please check that any required plugins are installed, or check the breaking changes documentation for removed settings",
```
