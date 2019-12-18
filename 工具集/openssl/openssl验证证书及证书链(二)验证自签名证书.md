# openssl验证证书及证书链(二)验证自签名证书

参考文章

1. [使用openssl校验证书链](http://www.zeali.net/entry/532)

2. [SSL自签署证书生成脚本](http://www.zeali.net/entry/532)

3. [Shell脚本实现生成SSL自签署证书](http://www.jb51.net/article/60371.htm)

4. [openssl生成证书链多级证书](http://www.cnblogs.com/gsls200808/p/4502044.html)

我们来做个比较复杂的实验吧.

首先生成根证书CA, 用它签发A, B两个中间证书, 再用A签发a证书, 整个证书链的层级关系如下

```
CA
├── A
│   └── a
├── B
```

按照如下步骤生成证书

首先生成根证书CA, 根证书不需要csr文件, 因为它不需要被签名

```
openssl req -new -x509 -days 36500 -extensions v3_ca -keyout CA.key -out CA.crt
```

然后生成二级CA A和B, 服务器证书a

```
openssl genrsa -out A.key 2048
openssl genrsa -out B.key 2048
openssl genrsa -out a.key 2048
openssl req -new -key A.key -out A.csr
openssl req -new -key B.key -out B.csr
openssl req -new -key a.key -out a.csr
```

> 注意, 每次生成`*.csr`文件时, `CN`的值都不要与签发者证书的一样. 比如`a`的CN值不能和`A`的一样, 不然会有问题的.

用CA证书为A, B签发证书

```
openssl x509 -req -extensions v3_ca -CA CA.crt -CAkey CA.key -CAcreateserial -days 36500 -in A.csr -out A.crt
openssl x509 -req -extensions v3_ca -CA CA.crt -CAkey CA.key -CAcreateserial -days 36500 -in B.csr -out B.crt
```

用二级CA A为a密钥签名

```
openssl x509 -req -CA A.crt -CAkey A.key -CAcreateserial -days 36500 -in a.csr -out a.crt
```

## 1. 验证根证书

验证自签发CA根证书时

```
$ openssl verify CA.crt
CA.crt: C = XX, L = Default City, O = Default Company Ltd, CN = 0.0.0.0
error 18 at 0 depth lookup:self signed certificate
OK
```

咳, csr信息只填了个`CN`...

它输出了`self signed certificate`, 表明openssl认为这是我们自签发的证书, 所以才有`error 18`. 

但这不是错误, 只是不被系统信任而已, 导入到系统的信任列表里就可以了, 关于如何导入等会再讨论. 

## 2. 验证证书链

首先验证`A.crt`

```
$ openssl verify A.crt
A.crt: C = XX, L = Default City, O = Default Company Ltd, CN = A
error 20 at 0 depth lookup:unable to get local issuer certificate
```

它不是根证书, 而是被人签发的.

使用`CA.crt`验证`A.crt`

```
$ openssl verify -CAfile CA.crt A.crt 
A.crt: OK
```

完美.

再用`A.crt`验证`a.crt`.

```
$ openssl verify -CAfile A.crt a.crt 
a.crt: C = XX, L = Default City, O = Default Company Ltd, CN = a
error 18 at 0 depth lookup:self signed certificate
OK
```

好像有点问题, 按照参考文章1说的, 把CA和A证书合并一下再验证

```
$ cat CA.crt A.crt > bundle.crt
$ openssl verify -CAfile bundle.crt a.crt 
a.crt: C = XX, L = Default City, O = Default Company Ltd, CN = a
error 18 at 0 depth lookup:self signed certificate
OK
```

还是这个问题, 但是和错误还不太搭边, 因为真正验证错误是下面这样的.

```
$ openssl verify -CAfile B.crt A.crt 
A.crt: C = XX, L = Default City, O = Default Company Ltd, CN = A
error 20 at 0 depth lookup:unable to get local issuer certificate
```

## 3. 信任根证书后验证

```
$ cp CA.crt /etc/pki/ca-trust/source/anchors/
$ update-ca-trust
```

重复上面的步骤试试.
