# Nginx-https.1.生成, 申请与配置[openssl]

环境需求:

- 如果目标服务器是Nginx, 则需要预先编译`http_ssl_module`支持.
- 如果目标服务器是Apache, 则需要安装`mod_ssl`模块.

安装方法见下文.

## 1. 引言

本文是关于nginx与apache开启https服务的操作记录. 暂时不深入研究`https`与`openssl`, 两个都是深坑...

关于https的背景与前景就不说了. https证书的获取一般免费的方式有两种: 本地生成和在线申请. 

- 本地生成虽然也能实现内容的加密, 但除了你自己, 没人能证明该连接是安全的, 如果是面向用户的话, 不会有人相信这样的网站是可以信任的. 
- 在线申请则是由被浏览器厂商承认的可靠的组织给你的站点颁发证书, 这样用户在访问你的网站时浏览器不会弹出下图中的提示, 用户也能更放心的访问.

![](https://gitee.com/generals-space/gitimg/raw/master/3d2e5ce8d56b7f1df393e94d37e1a95b.jpg)

本地申请与在线申请的原理其实都一样, 只不过一个是自己给自己签名, 另一个是由CA机构给自己签名. 

有点像考试成绩单, 一个是自己给自己伪造成绩单然后伪造签名, 另一个是班主任发的成绩单, 带有"官方签名".

...当然, 自己伪造的成绩单, 家长还是会有点"警觉"的🧐, 不可信!!!

## 2. 获取证书

### 2.1 本地生成

linux可以给自己颁发证书, 用到的工具是`openssl`命令, 需要事先安装`openssl openssl-dev`包.

#### 2.1.1 生成server.key私钥文件

执行第一条指令会提示输入密码, 生成的文件是**服务器的私钥.key文件**, 密码是为了加密该私钥. 不输入会提示错误...还不让你退出, 倒是没有字符类型及个数的限制. **记得要保存好这个密码, 有时启动服务器是需要它的.**

```log
$ openssl genrsa -des3 -out server.key 1024
Generating RSA private key, 1024 bit long modulus
................................++++++
..........++++++
e is 65537 (0x10001)
Enter pass phrase for server.key:
Verifying - Enter pass phrase for server.key:
```

#### 2.1.2 生成server.csr信息文件

第二条指令会提示输入第一条你输入的密码, 这一步生成的是`csr(Certificate Signing Request)`文件, 可以将它看成是你的信息文件(就是我们的**成绩单**), 将它提交给CA证书机构时就可以根据这里面的信息为你的站点证书签名. **注意: 其他的信息无所谓, 但Common Name必须填写, 否则无法建立ssl链接, 它的值是你的顶级域名(或localhost).**

```log
$ openssl req -new -key server.key -out server.csr
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

#### 2.1.3 为server.csr签名, 生成server.crt证书文件

```log
$ openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
Signature ok
subject=/C=XX/L=Default City/O=Default Company Ltd/CN=generals.space
Getting Private key
Enter pass phrase for server.key:

```

这里得到的`server.crt`与第1步得到的`server.key`, 就可以配置到nginx了.

### 2.2 在线申请

免费的CA机构有`startssl`与`沃通`等, 这两者的证书申请可能有些不同, 并且网上大部分教程与现在的申请流程也不再完全适用, 但基本流程大多相似. 这里不做具体的申请示范.

一般来说, 在这些网站上完成注册之后, 首先需要验证你将要为之申请的域名, 证明你是这个域名的所有者, 然后CA会批准为你的这个域名进行签名, 让浏览器信任它. 一般免费的途径只能为~~5~~有限个域名颁发证书. **域名可以是顶级域名或是二级域名, 但顶级域名不能是泛解析形式的**.

然后你需要提供`key`与`csr`文件, 一个是服务器私钥, 一个是你的信息文件, 这两者可以本地生成, 貌似也可以使用工具. CA机构会为你的`csr`(成绩单)文件签名生成证书. 然后下载下来就可以了.

> PS: csr文件中Common Name填的是顶级域名, 但好像没有网站是全站都是https的, 只有类似mail这样的子域名才需要https, 所以不要妄想一个证书能为一个顶级域名下的所有子域名加密...

## 3. 服务器配置

Nginx可以使用`nginx -V`查看编译选项, 如果没有`--with-http_ssl_module`, 只能重新编译. 一般来说, 通过源方式安装的nginx都会编译有该模块;

nginx开启https需要两个文件: key与crt文件. 示例配置信息如下

```conf
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

```log
$ nginx -s reload
Enter PEM pass phrase:
```

现在应该可以访问你的https站点了.

事实上, 只要修改crt与key文件路径, 其他保持默认就好了. 同样, 在启动apache时也会提示输入私钥密码.

> PS: 本地生成的证书浏览器都会予以警告, 解除这种警告的方法就是, 将本地生成的crt证书导入浏览器.

> 可以使用`openssl`命令移除私钥密码, 否则每次重启服务都需要输入, 很麻烦.

## 4. 总结 & FAQ

本文只是写出为服务器开启https支持的步骤. 更深入的研究可以参考本系列的下一篇文章.
