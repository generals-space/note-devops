## 1. mosquitto日志报错SSL routines:SSL3_READ_BYTES:tlsv1 alert unknown ca

参考文章

1. [Mosquitto服务器的搭建以及SSL/TLS安全通信配置](https://segmentfault.com/a/1190000005079300)

2. [Mosquitto SSL Configuration -MQTT TLS Security 读者Abhinav Saxena的评论](http://www.steves-internet-guide.com/mosquitto-tls/)

3. [OpenSSL - error 18 at 0 depth lookup:self signed certificate](https://stackoverflow.com/questions/19726138/openssl-error-18-at-0-depth-lookupself-signed-certificate)

系统版本: CentOS7

mosquitto版本: 1.4.15

openssl版本: 1.0.1e

参考文章1对mosquitto的TLS配置步骤讲解得十分详细, 包含了openssl生成证书及密钥, mosquitto的配置, 及其内置pub/sub客户端对证书及密钥的使用等. 

其实关于`mosquitto`的自签名SSL/TLS配置, 在用yum安装后可以使用`man mosquitto-tls`查看, 其中也有详细的操作步骤.

按照这样的流程走下来, `mosquitto`启动正常, 相关配置如下.

```
cafile /etc/mosquitto/certs/ca.crt
certfile /etc/mosquitto/certs/server.crt
keyfile /etc/mosquitto/certs/server.key
tls_version tlsv1
```

没什么问题, 但是在执行`mosquitto_pub`, `mosquitto_sub`命令时, 得到了`Error: A TLS error occurred.`错误.

```
$ mosquitto_pub  -t 'room01/sensors' -m '我的消息' --cafile /etc/mosquitto/certs/ca.crt --cert /etc/mosquitto/certs/client.crt --key /etc/mosquitto/certs/client.key -h 172.32.100.10 --tls-version tlsv1
Error: A TLS error occurred
```

对应的, mosquitto服务端的日志如下.

```
1523024283: New connection from 172.32.100.10 on port 1883.
1523024283: OpenSSL Error: error:14094418:SSL routines:SSL3_READ_BYTES:tlsv1 alert unknown ca
1523024283: OpenSSL Error: error:140940E5:SSL routines:SSL3_READ_BYTES:ssl handshake failure
1523024283: Socket error on client <unknown>, disconnecting.
```

> `--tls-version tlsv1`选项要加的, 因为`pub/sub`两个客户端使用的tls版本默认为`tls1.2`, 不加这个选项的话, mosquitto服务会得到`SSL routines:SSL3_READ_BYTES:tlsv1 alert protocol version`错误.

网上关于这个问题有说是因为mosquitto与两个客户端版本不一致的, 或者mosquitto指定`ca.crt`与客户端不是同一个的, 也有说是server.csr填写的`Common Name`与服务器IP不同的...

呵呵, 可笑, 我怎么可能会犯这种低级错误.

我也尝试过为`mosquitto_pub`加上`--insecure`选项, 但是这是让`mosquitto_pub`不去验证服务端证书中`Common Name`与其地址是否匹配的, 无效.

后来按照参考文章2中`Abhinav Saxena`的提示, 把`--cafile`的值改成了`server.crt`, 竟然成功了...成功了...

```
$ mosquitto_pub  -t 'room01/sensors' -m '我的消息' --cafile /etc/mosquitto/certs/ca.crt --cert /etc/mosquitto/certs/client.crt --key /etc/mosquitto/certs/client.key -h 172.32.100.10 --tls-version tlsv1
```

`mosquitto_sub`的命令如下

```
$ mosquitto_sub  -t 'room01/sensors' -h 172.32.100.10 --tls-version tlsv1 --cafile /etc/mosquitto/certs/server.crt --cert /etc/mosquitto/certs/client.crt --key /etc/mosquitto/certs/client.key
我的消息
```

服务端的日志如下

```
1523175367: New connection from 172.32.100.10 on port 1883.
1523175368: New client connected from 172.32.100.10 as mosqpub|6211-localhost. (c1, k60).
1523175368: Sending CONNACK to mosqpub|6211-localhost. (0, 0)
1523175368: Received PUBLISH from mosqpub|6211-localhost. (d0, q0, r0, m0, 'room01/sensors', ... (12 bytes))
1523175368: Received DISCONNECT from mosqpub|6211-localhost.
1523175368: Client mosqpub|6211-localhost. disconnected.
```

如果加了`--insecure`选项, 命令应该是这样的

```
$ mosquitto_pub  -t 'room01/sensors' -m '我的消息' -h 172.32.100.10 --tls-version tlsv1 --cafile /etc/mosquitto/certs/server.crt --insecure
```

对应的, `moquitto_sub`的命令应该写做

```
$ mosquitto_sub  -t 'room01/sensors' -h 172.32.100.10 --tls-version tlsv1 --cafile /etc/mosquitto/certs/server.crt --insecure
我的消息
```

我的世界观都崩塌了...

之后的实验里, 认识到上面的TLS只是mosquitto的单向认证, 这种情况下, 是要客户端判断服务端是否可信的, 就是说, 这种认证是为了客户端的安全而不是服务端安全. 

`mosquitto`还有一个`require_certificate`字段, 表示是否验证客户端传来的证书, 默认为`fasle`.

> ...呵呵, 如果没验证客户端证书, 那上面的错误是怎么来的???

不过, 将这个字段设置为`true`后, 上面两种订阅/发布命令都没用了.

心累.jpg, md一定是`mosquitto_pub/sub`两个命令有问题!

------

隐隐觉得还是和证书的`Common Name`字段有关, 之前的测试中, `mosquitto`服务与`pub/sub`客户端是在同一台服务器上. 尝试在另一台服务器运行`mosquitto_pub`命令, 所以重新为其签发了证书与密钥对, 然后运行成功了.

于是猜测, 是不是`CA`的`Common Name`不能与被其签发的证书的相同? 因为之前测试时, CA, server与client的`Common Name`都是`172.32.100.10`(之前也试过localhost, 127.0.0.1的).

然后重新生成CA证书, `Common Name`填的是`0.0.0.0`, server与client的依然是服务器本身的IP`172.32.100.10`.

事实证明我的猜测是对的.

网上大家人都只说`mosquitto`与其客户端的证书`Common Name`要与其所在服务器IP相符, 却没有人说过自签名的CA证书`Common Name`应该取什么, 总有人踩坑的.

关于这一点, 可以看一下参考文章3的最佳答案, 一票人来感谢这个回答...

> When OpenSSL prompts you for the Common Name for each certificate, use different names.