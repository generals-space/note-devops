# https分析(一)-Nginx及Apache配置https证书

<!tags!>: <!nginx!> <!https!>

环境需求:

- 如果目标服务器是Nginx, 则需要预先编译`http_ssl_module`支持.

- 如果目标服务器是Apache, 则需要安装`mod_ssl`模块.

安装方法见下文.

## 1. 引言

本文是关于nginx与apache开启https服务的操作记录. 暂时不深入研究`https`与`openssl`, 两个都是深坑...

关于https的背景与前景就不说了. https证书的获取一般免费的方式有两种: 本地生成和在线申请. 本地生成虽然也能实现内容的加密, 但除了你自己, 没人能证明该连接是安全的, 如果是面向用户的话, 不会有人相信这样的网站是可以信任的. 在线申请则是由被浏览器厂商承认的可靠的组织给你的站点颁发证书, 这样用户在访问你的网站时浏览器不会弹出下图中的提示, 用户也能更放心的访问.

![](https://gitee.com/generals-space/gitimg/raw/master/3d2e5ce8d56b7f1df393e94d37e1a95b.jpg)

本地申请与在线申请的原理其实都一样, 只不过一个是自己给自己签名, 另一个是由CA机构给自己签名. 有点像考试成绩单, 一个是自己给自己伪造成绩单然后伪造签名, 另一个是班主任发的成绩单, 带有"官方签名"...当然, 你自己伪造的成绩单, 家长还是会有点"警觉"的, 不可信!!!.

## 2. 获取证书

### 2.1 本地生成

linux可以给自己颁发证书, 用到的工具是`openssl`命令, 需要事先安装`openssl openssl-dev`包.

cd到某个目录, 执行如下命令, 生成本地https证书

执行第一条指令会提示输入密码, 生成的文件是**服务器的私钥.key文件**, 密码是为了加密该私钥. 不输入会提示错误...还不让你退出, 倒是没有字符类型及个数的限制. **记得要保存好这个密码, 有时启动服务器是需要它的.**

```
[root@iZ28xsa51i1Z]# openssl genrsa -des3 -out server.key 1024
Generating RSA private key, 1024 bit long modulus
................................++++++
..........++++++
e is 65537 (0x10001)
Enter pass phrase for server.key:
Verifying - Enter pass phrase for server.key:
```

第二条指令会提示输入第一条你输入的密码, 这一步生成的是`csr(Certificate Signing Request)`文件, 可以将它看成是你的信息文件(就是我们的**成绩单**), 将它提交给CA证书机构时就可以根据这里面的信息为你的站点证书签名. **注意: 其他的信息无所谓, 但Common Name必须填写, 否则无法建立ssl链接, 它的值是你的顶级域名(或localhost).**

```
[root@iZ28xsa51i1Z]# openssl req -new -key server.key -out server.csr
Enter pass phrase for registry.sky-mobi.com.key:                       ## 这里输入密码
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server\'s hostname) []:你的顶级域名或者localhost
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:                                ## 可不写
An optional company name []:                            ## 可不写
```

第三条指令是代替CA机构给自己的csr文件签名, 生成的crt文件就是可用证书.

```
[root@iZ28xsa51i1Z]# openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
Signature ok
subject=/C=XX/L=Default City/O=Default Company Ltd/CN=generals.space
Getting Private key
Enter pass phrase for server.key:

```

### 2.2 在线申请

免费的CA机构有`startssl`与`沃通`等, 这两者的证书申请可能有些不同, 并且网上大部分教程与现在的申请流程也不再完全适用, 但基本流程大多相似. 这里不做具体的申请示范.

一般来说, 在这些网站上完成注册之后, 首先需要验证你将要为之申请的域名, 证明你是这个域名的所有者, 然后CA会批准为你的这个域名进行签名, 让浏览器信任它. 一般免费的途径只能为~~5~~有限个域名颁发证书. **域名可以是顶级域名或是二级域名, 但顶级域名不能是泛解析形式的**.

然后你需要提供`key`与`csr`文件, 一个是服务器私钥, 一个是你的信息文件, 这两者可以本地生成, 貌似也可以使用工具. CA机构会为你的`csr`(成绩单)文件签名生成证书. 然后下载下来就可以了.

> PS: csr文件中Common Name填的是顶级域名, 但好像没有网站是全站都是https的, 只有类似mail这样的子域名才需要https, 所以不要妄想一个证书能为一个顶级域名下的所有子域名加密...

## 3. 服务器配置

Nginx可以使用`nginx -V`查看编译选项, 如果没有`--with-http_ssl_module`, 只能重新编译. 一般来说, 通过源方式安装的nginx都会编译有该模块;

nginx开启https需要两个文件: key与crt文件. 示例配置信息如下

```shell
server {
        listen       443 ssl;
        server_name  你的域名;
        root        你的网站目录;
        index index.php;
        ssl on;
        ssl_certificate crt文件路径, 相对路径以conf为根目录;
        ssl_certificate_key key文件路径, 相对路径也conf为根目录;
        ssl_session_timeout 5m;
        ssl_protocols SSLv2 SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ##ssl_ciphers HIGH:!aNULL:!MD5;
        ##ssl_prefer_server_ciphers on;
}
```

理论上说这样的配置已经可以了, 在不知道其应用时机时, 不要多写, 不要乱写...

这样每次nginx在(重新)启动时会提示输入key私钥的密码.

```shell
[root@iZ28xsa51i1Z]# nginx -s reload
Enter PEM pass phrase:
```

现在应该可以访问你的https站点了.

事实上, 只要修改crt与key文件路径, 其他保持默认就好了. 同样, 在启动apache时也会提示转入私钥密码.

> PS: 本地生成的证书浏览器都会予以警告, 解除这种警告的方法就是, 将本地生成的crt证书导入浏览器.

## 4. 总结

本文只是写出为服务器开启https支持的步骤. 更深入的研究可以参考本系列的下一篇文章.

------

不可避免的, 在配置过程中遇到了许多错误. 其中最让人心碎的如下图所示.

![]()

在问题解决之前, 我检讨出无数错误, 包括创建`csr`文件时域名填写是否正确, 不填会不会出错; 系统时间是否需要与本地时间一致(现在想想这个问题真是低级, 访问者总不可能全部是你本地的吧...); 客户端是不是需要导入对应的证书...

然而这个错误在一次配置正确之后再也没法重现了. 无论重新生成`csr`时如何乱写或不写, 生成的`crt`证书都是正确的, 本地生成与在线申请都是, 连`Common Name`域名的对应关系都可以随便写, 为`www.test1.com`申请的证书, 给`www.test2.com`用都没关系(只不过好像会被认定为**不被信任的链接**)...

还有, nginx服务器, 在某种情况下访问https页面, 也会出现上图所示的错误. 在nginx的`error.log`中有如下报错.

```shell
2016/06/15 13:48:33 [emerg] 25391#0: SSL_CTX_use_PrivateKey_file("/etc/nginx/server.key") failed (SSL: error:0906406D:PEM routines:PEM_def_callback:problems getting password error:0907B068:PEM routines:PEM_READ_BIO_PRIVATEKEY:bad password read error:140B0009:SSL routines:SSL_CTX_use_PrivateKey_file:PEM lib)
```

解决方法参考[这里](http://stackoverflow.com/questions/18101217/error-102-nginx-ssl)

其实就是因为服务器的私钥存在密码, nginx貌似无法正确解析key文件. 所以需要将先将私钥的密码除去. 如果你讨厌每次启动nginx/apache时都输入私钥密码, 也可以使用用这种方法.

```shell
openssl rsa -in server.key -out server_nopwd.key
```

然后在nginx配置文件中引入这个`server_nopwd.key`, 再重新启动即可.

这个问题同样无法重现了, 现在无论怎么加密, nginx都可以正常的加载key...悲催.

### 4.2

```log
2016/10/23 19:56:14 [emerg] 35175#0: SSL_CTX_use_PrivateKey_file("/usr/local/nginx/con
f/server.key") failed (SSL: error:0906406D:PEM routines:PEM_def_callback:problems gett
ing password error:0906A068:PEM routines:PEM_do_header:bad password read error:140B000
9:SSL routines:SSL_CTX_use_PrivateKey_file:PEM lib)
```

情景描述: nginx配置文件验证显示正确, 也能成功重启, 但是没有监听443端口. error.log中报上述错误.

原因分析: https的`.key`文件有密码, 虽然重启时输入了密码, 但nginx貌似没办法正确使用. 

解决方法: 使用下面的密码移除命令, 将`.key`的密码移除, 加载没有密码的`.key`文件再次重启即可.

### 4.3 

使用第三方认证机构进行证书签名时, 需要指定要使用的顶级域名或二级域名. 访问目标网站与配置的证书不符时, 会显示"不安全的连接", 情况大致如下.

![](https://gitee.com/generals-space/gitimg/raw/master/cce096442576ff9b29222879af44b7f7.png)

![](https://gitee.com/generals-space/gitimg/raw/master/593f860cbebbb8704177c9ff6128154d.jpg)

![](https://gitee.com/generals-space/gitimg/raw/master/d11b57c48a4e2a1cb8e1fb8833a11ce3.jpg)

可以看到chrome与firefox中都提到该域名的证书是为`databegin.com`申请的, 虽然在服务器上配置了`www.databegin.com`也使用这个证书, 但由于没有为`www`这个子域名进行签名, 所以浏览器认为此网站不安全.

当然, 还有一种情况是, 自己本地为自己颁发证书, 这样也会导致上述图片中的警告.

## 5. 扩展

### 5.1

上面生成的服务器key文件是带有密码的, 以后使用`nginx -t`和`nginx -s reload`方法时都会提示输入密码, 太麻烦.

解决办法是, 去除这个key上的密码, 这会生成一个新的不带密码key文件.

```
$ openssl rsa -in 有密码的key文件名 -out 将要生成的无密码的key文件名
```

在nginx中将原来的key替换为无密码的key, 证书依然可以使用.
