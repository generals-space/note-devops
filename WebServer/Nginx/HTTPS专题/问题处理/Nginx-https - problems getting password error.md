# Nginx-https - problems getting password error

参考文章

1. [Error 102 nginx SSL](http://stackoverflow.com/questions/18101217/error-102-nginx-ssl)

不可避免的, 在配置过程中遇到了许多错误. 其中最让人心碎的如下图所示.

![找不到图了]()

在问题解决之前, 我检讨出无数错误, 包括创建`csr`文件时域名填写是否正确, 不填会不会出错; 系统时间是否需要与本地时间一致(现在想想这个问题真是低级, 访问者总不可能全部是你本地的吧...); 客户端是不是需要导入对应的证书...

然而这个错误在一次配置正确之后再也没法重现了. 无论重新生成`csr`时如何乱写或不写, 生成的`crt`证书都是正确的, 本地生成与在线申请都是, 连`Common Name`域名的对应关系都可以随便写, 为`www.test1.com`申请的证书, 给`www.test2.com`用都没关系(只不过好像会被认定为**不被信任的链接**)...

## 1. 场景描述

nginx配置文件验证显示正确, 也能成功重启, 但是没有监听443端口. 在nginx的`error.log`中有如下报错.

```log
2016/06/15 13:48:33 [emerg] 25391#0: SSL_CTX_use_PrivateKey_file("/etc/nginx/server.key") failed (SSL: error:0906406D:PEM routines:PEM_def_callback:problems getting password error:0907B068:PEM routines:PEM_READ_BIO_PRIVATEKEY:bad password read error:140B0009:SSL routines:SSL_CTX_use_PrivateKey_file:PEM lib)
```

## 2. 解决方法

见参考文章1.

其实就是因为服务器的私钥存在密码, nginx貌似无法正确解析key文件. 所以需要将先将私钥的密码除去. 如果你讨厌每次启动nginx/apache时都输入私钥密码, 也可以使用用这种方法.

```
openssl rsa -in server.key -out server_nopwd.key
```

然后在nginx配置文件中引入这个`server_nopwd.key`, 再重新启动即可.

这个问题同样无法重现了, 现在无论怎么加密, nginx都可以正常的加载key...悲催.
