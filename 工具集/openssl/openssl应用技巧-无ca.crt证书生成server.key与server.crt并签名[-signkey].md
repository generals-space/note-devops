# openssl应用技巧-无ca.crt证书生成server.key与server.crt并签名[-signkey]

忘了啥时候写的了, 也不知道哪种场景才会有这样需求.

1. 首先生成私钥key文件, 会要求输入密码

```
openssl genrsa -des3 -out server.key 2048
```

2. 生成csr证书签名请求文件, 也可以理解为对应的公钥文件. 这一步需要填写一写信息.

```
openssl req -new -key server.key -out server.csr
```

3. 直接对csr与key密钥对签名(两个文件需要同时传入), 生成crt证书文件

```
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```
