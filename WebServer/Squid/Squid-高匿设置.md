# Squid-高匿设置

参考文章

1. [squid 高匿设置](https://www.cnblogs.com/vijayfly/p/5800038.html)

## 1. 代理相关的请求头字段

首先理解http请求头中的3个参数:

1. `Remote Address`

这个值的格式为`IP:port`. 注意: 在浏览器端也可以看见, 但是和服务器端看到的值是不同的. 

在客户端(特指浏览器), 这个值表示目标服务器的IP地址与端口, 是经过DNS解析后得到的IP和端口. 如果客户端配置了代理(不管是http还是ss), 这个值都会变成代理服务器的地址和端口. 之所以特指浏览器是因为使用`curl`命令是没法看到这个字段的, 只能在浏览器的控制台中看到, 实际上这个字段在客户端根本没有意义, 它只表示请求要发往哪一个地址且客户端无法更改.

在服务端, 这个字段的值为客户端请求的来源地址. 但是客户端使用了代理时, 这个值就会变成代理的地址.

2. `X-Forwarded-For`

用户正常的, 不经过代理的访问请求的请求头中是不带有这个字段的. 只有经过了代理, 且代理的隐匿性不那么严格时, 会把用户的真实IP写在这个字段里. 

3. `Via`

正常的请求头中也不会有这个字段, 只有在经过代理, 且代理本身的安全意识不够的情况下, 才会出现. 它的含义是代理服务器的地址. squid默认不会添加这个字段的.

## 2. 代理的分类

通过判断 **用户是否经过了代理**, **用户的真实IP是什么**, ~~用户使用的代理IP是什么~~等问题, 根据代理对用户信息及自身信息的保密程度, 可以将代理分为如下几类:

`高匿 > 混淆 > 匿名 > 透明 > 高透`

### 2.1. 高透代理(High Transparent Proxy): 单纯地转发数据

```
Remote Address = 客户端IP
X-Forwarded-For = 客户端IP
Via = 客户端IP
```

只是单纯转发数据, 目标服务器知道你在使用代理, 也知道你的IP, 但是没有暴露代理本身的地址.

### 2.2. 透明代理(Transparent Proxy): 知道你在用代理, 知道你IP

```
Remote Address = 代理IP
X-Forwarded-For = 客户端IP
Via = 代理IP
```

目标服务器知道你在使用代理, 也知道你的IP, 也知道代理的IP. 

> 我感觉这个才是高透...代理的IP不能暴露吧, 这样代理也可能被封掉.

### 2.3. 匿名代理(Anonymous Proxy): 知道你用代理, 不知道你IP

```
Remote Address = 代理IP
X-Forwarded-For = 代理IP
Via = 代理IP
```

### 2.4. 高匿代理(High Anonymity Proxy): 不知道你在用代理

```
Remote Address = 代理IP
X-Forwarded-For = N/A
Via = N/A
```

> 这里的`N/A`应该不是空, 而是直接不设置这两个值, 这样经过代理的请求就和不经过代理的请求完全没有区别, 目标服务器会认为这是一个普通的用户请求.

### 2.5. 混淆代理（Distorting Proxies）：知道你在用代理，但你的IP是假的

```
Remote Address = 代理IP
X-Forwarded-For = 随机IP
Via = 代理IP
```

## 3. squid的设置

squid默认会更改`Remote Address`和`X-Forwarded-For`, 不会出现`Via`字段.

通过设置如下字段的`deny`与`allow`, 可以让到目标服务器的请求头中出现/隐藏这两个字段.

```
request_header_access Via deny all
request_header_access X-Forwarded-For deny all
```