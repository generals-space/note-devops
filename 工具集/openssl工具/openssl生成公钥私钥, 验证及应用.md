# openssl生成公钥私钥

参考文章

1. [使用 openssl 生成证书（含openssl详解）](https://blog.csdn.net/gengxiaoming7/article/details/78505107)

2. [使用OpenSSL生成RSA公钥和私钥](https://blog.csdn.net/mq2856992713/article/details/52579202)

3. [使用openssl生成RSA公钥和私钥对](https://blog.csdn.net/sean_cd/article/details/53523090)

4. [openssl 证书 及ssh密匙](https://www.jianshu.com/p/e68be0ac90ff)

5. [openssl 通过公钥/私钥加解密文件](https://blog.csdn.net/makenothing/article/details/54645578)

## 1. 基本步骤

1. 首先生成RSA私钥

```
$ openssl genrsa -out private.key 2048
Generating RSA private key, 2048 bit long modulus
......................+++
.....+++
e is 65537 (0x10001)
```

这会在当前目录生成一个`private.key`文件, 这就是私钥文件.

2. 然后生成与此私钥对应的公钥文件

```
$ openssl rsa -in private.key -pubout -out public.key
writing RSA key
```

这一步会得到`public.key`文件, 正是我们需要的公钥文件.

也有说用原始的RSA私钥再生成`pkcs#8`格式的私钥的, 但谁都没提过用这种格式的密钥来做什么...

```
$ openssl pkcs8 -topk8 -inform PEM -in private.key -outform PEM –nocrypt
```

...不过这个密钥对应该不能用作ssh验证, 因为证书格式都不一样. 而且网上也没有直接用`openssl`命令生成ssh所需密钥的示例.

那能用它们来做什么呢?

引用参考文章4中的概念

> 公钥和私钥都可以用来加密数据, 然后用另一个解开. 公钥加密数据, 然后私钥解密的情况被称为**加密解密**. 私钥加密数据, 公钥解密一般被称为**签名和验证签名**. 

下面来测试一下.

## 2. 验证签名

创建一个测试文件.

```
$ echo '1234' > test.txt
```

用私钥给文件签名

```
$ openssl pkeyutl -sign -in test.txt -inkey private.key -out test.sig
```

生成的`test.sig`是一个二进制文件.

用公钥验证签名

```
$ openssl pkeyutl -verify -in test.txt -sigfile test.sig -pubin -inkey public.key 
Signature Verified Successfully
```

用公钥恢复签名文件的内容

```
$ openssl pkeyutl -verifyrecover -in test.sig -pubin -inkey public.key 
1234
```

## 3. 加解密

公钥加密文件

```
$ openssl pkeyutl -encrypt -in test.txt -pubin -inkey public.key -out test.enc
```

私钥解密文件

```
$ openssl pkeyutl -decrypt -in test.enc -inkey private.key -out test.dec
$ cat test.dec 
1234
```

后来我又尝试着用了下之前`pkcs#8`格式的私钥去解密, 还成功了...

```
$ openssl pkeyutl -decrypt -in test.enc -inkey pkcs8_pri.key -out test.dec
$ cat test.dec 
1234
```

然后返回去又用`pkcs8_pri.key`为文件签名, 也能被`public.key`验证成功.

所以说经过`pkcs`格式化后, 私钥的角色是没变的, 同样能完成加解密和签名工作.

------

...不过签名和加密的感觉差不多啊, 只不过是反过来用的而已.