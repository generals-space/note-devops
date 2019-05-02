# 部署Let's Encrypt免费SSL证书&&自动续期

参考文章

1. [部署Let’s Encrypt免费SSL证书&&自动续期](http://www.linuxidc.com/Linux/2017-03/142248.htm)

2. [Let's Encrypt官网链接](https://letsencrypt.org/getting-started/)

3. [Certbot官网链接](https://certbot.eff.org/#centosrhel7-nginx)

Let's Encrypt提供了一个工具命令, 托管在CentOS下的epel源中(实际上它支持多个操作系统, 在官网上你可以自行选择, 然后得到可行的部署流程).

## 1. 流程

以CentOS7为例.

首先使用yum安装`cerbot-nginx`工具包.

```
$ yum install certbot-nginx
```

然后可以得到`certbot`命令.

> 注意: 不同版本的系统/Web服务器的安装方法不同, 你需要在官网上自行选择.

然后执行

```
$ certbot --nginx
```

这一步, 是`certbot`为你完成如下步骤提供的傻瓜导航. 在普通情况下, 你可能需要完成如下流程才能配置好一个证书.

1. 注册startSSL

2. 验证域名所有权

3. 生成证书

4. CA签名

5. 下载证书

6. nginx配置证书并重启

`certbot`简化了这一流程(不过, 事先知晓证书申请的通用流程会让心里更有底). 

我们仍然需要一个邮箱, certbot会为我们自动完成注册流程, 它会查询nginx默认配置文件路径, 最后得到其中所有`server_name`字段. 

在交互式命令行中, 它会提示你想要为哪个或哪些域名申请证书, 根据自己的需要进行选择即可.

生成证书是一个非常快的过程, 无需等待多长时间. 完成后命令行中会提示保留http服务, 让http与https共存, 还是只开启https.

![](https://gitee.com/generals-space/gitimg/raw/master/9f0d56711891f45568bb0c3e3877d03f.png)

你完成选择后, 它会改写nginx的配置文件并重启.

例如, 它在我的nginx配置文件中加了如下行

![](https://gitee.com/generals-space/gitimg/raw/master/b16b4ffaaae14257e90bd135162221b1.png)

注意:

1. 貌似`certbot`只支持默认安装的nginx, 不然它找不到nginx配置文件路径. 源码安装的nginx, 可以使用软链接将自定义nginx的`conf`目录软链接到`/etc/nginx`.

2. 如果nginx中原本存在证书, 也会被替换成`certbot`新生成的证书路径, 即`ssl_certificate`与`ssl_certificate_key`字段将被修改.

## 2. 延期

默认生成的证书有效时间为90天(真是严格的90天了...而不是3个月后的今天), 我们还需要设置其定时更新的策略.

![](https://gitee.com/generals-space/gitimg/raw/master/8ab4e3702fbf15e5cb84e9ff291858fc.png)

`certbot`官网提供了解决方案, 也是由`certbot`命令提供的. 首先使用如下命令进行检测

```
$ certbot renew --dry-run
```

如果执行成功, 说明当前服务器可以完成在线更新行为, 然后将如下命令写在crontab中定时执行以保证我们的证书长久有效.

```
/usr/bin/certbot renew
```

------

要添加新的域名也是很方便的, 在已经安装过Let's Encrypt证书的机器上再次执行`certbot --nginx`就会让你直接选域名了, 不必再次输入邮箱什么的信息. 简单快捷!