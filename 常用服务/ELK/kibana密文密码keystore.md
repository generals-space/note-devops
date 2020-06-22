# kibana密文密码keystore

参考文章

1. [<十三>ELK-学习笔记–elasticsearch-7.x使用xpack进行安全认证](http://www.eryajf.net/3500.html)

ELK版本: 7.2.0

一般我们通过在`kibana.yml`配置文件写如下字段作为 kibana 连接 es 的认证手段.

```yaml
elasticsearch.username: elastic
elasticsearch.password: "123456"
```

但这是明文的, 一定有场景更希望不要存在明文密码.

移除配置文件`kibana.yml`中的`username`和`password`这两个键, 然后调用`kibana-keystore`, 执行如下命令.

```console
$ ./kibana-keystore create
Created Kibana keystore in /usr/share/kibana/data/kibana.keystore
$ ./kibana-keystore add elasticsearch.username
Enter value for elasticsearch.username: *******  ## elastic
$ ./kibana-keystore add elasticsearch.password
Enter value for elasticsearch.password: ******   ## 123456
```

然后重启 kibana, 和明文密码时完全相同.

参考文章1中说要加`xpack.reporting.encryptionKey`和`xpack.security.encryptionKey`两个键, 否则会出错, 但实际在测试时并不会.
