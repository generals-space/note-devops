参考文章

1. [OpenSSL 的使用详解](http://www.178linux.com/48764)
2. [Linux如何使用OpenSSL命令行](http://www.xitongzhijia.net/xtjc/20150327/43137_all.html)
    - base64编码/解码
    - 摘要算法校验文件的一致性
    - 文件加密/解密

## 1. 明确概念

OpenSSL是一个开源项目，其组成主要包括一下三个组件：

1. openssl: 多用途的命令行工具
2. libcrypto: 加密算法库, 包括md5, sha1等
3. libssl: 加密模块应用库，实现了ssl及tls协议

openssl命令行工具可以实现: 秘钥证书管理、对称加密和非对称加密(或解密)以及一些其他常用功能(比如生成随机字符串).

`libcrypto`与`libssl`在各种语言中都提供了API(我感觉`openssl`命令行工具应该是它在bash环境中的API...)

## 2. openssl命令行

关于openssl在命令行的使用方法, 可以使用`openssl --help`查看. 

```console
$ openssl --help
openssl:Error: '--help' is an invalid command.

Standard commands
asn1parse         ca                ciphers           cms               
...

Message Digest commands (see the `dgst' command for more details)
md2               md4               md5               rmd160            
...

Cipher commands (see the `enc' command for more details)
aes-128-cbc       aes-128-ecb       aes-192-cbc       aes-192-ecb       
...
```

可以看到, openssl的子命令分为3种

1. 标准子命令
2. 信息摘要算法子命令
3. 数据加密算法子命令

> ...关于摘要算法与加密算法的区别, 数据摘要算法不可逆主要用于验证与比对，加密算法由于可逆性, 可以进行加解密.

