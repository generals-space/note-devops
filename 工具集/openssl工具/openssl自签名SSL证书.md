# openssl自签名SSL证书

## 术语含义

*.key: 通常指私钥.

*.csr: 是`Certificate Signing Request`的缩写, 即证书签名请求, 这不是证书, 可以简单理解成公钥(但还包含了一些其他的信息), 生成证书时要把这个提交给权威的证书颁发机构.

*.crt 即 certificate的缩写, 即证书.

x.509 是一种证书格式.对X.509证书来说, 认证者总是CA或由CA指定的人, 一份X.509证书是一些标准字段的集合, 这些字段包含有关用户或设备及其相应公钥的信息.

x.509的证书文件, 一般以.crt结尾, 根据该文件的内容编码格式, 可以分为以下二种格式: 

PEM - Privacy Enhanced Mail,打开看文本格式,以"-----BEGIN..."开头, "-----END..."结尾,内容是BASE64编码.
Apache和*NIX服务器偏向于使用这种编码格式.

DER - Distinguished Encoding Rules,打开看是二进制格式,不可读.
Java和Windows服务器偏向于使用这种编码格式

## 2. 无CA直接签名

1. 首先生成私钥key文件, 会要求输入密码

`openssl genrsa -des3 -out server.key 2048`

2. 生成csr证书签名请求文件, 也可以理解为对应的公钥文件. 这一步需要填写一写信息.

`openssl req -new -key server.key -out server.csr`

3. 直接对csr与key密钥对签名(两个文件需要同时传入), 生成crt证书文件

`openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt`

## 3. 生成CA再签名

1. 生成CA的证书与私钥key文件, CA是不需要csr文件的, 因为它不需要被签名.

`openssl req -new -x509 -days 36500 -extensions v3_ca -keyout ca.key -out ca.crt`

2. 像上面那样生成key文件与csr文件

`openssl genrsa -des3 -out server.key 2048`
`openssl req -new -key server.key -out server.csr`

3. 用我们生成的CA证书, 为我们自己的key签名, 并生成crt文件.

`openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -days 36500 -in server.csr -out server.crt`