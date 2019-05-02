# openssl验证证书及证书链

参考文章

1. [使用openssl校验证书链](http://www.zeali.net/entry/532)

2. [SSL自签署证书生成脚本](http://www.zeali.net/entry/532)

3. [Shell脚本实现生成SSL自签署证书](http://www.jb51.net/article/60371.htm)

4. [openssl生成证书链多级证书](http://www.cnblogs.com/gsls200808/p/4502044.html)

- 系统版本: CentOS7

- openssl版本: 1.0.1e

首先要明确, 证书签发一般是**链式结构**. 根证书(Root CA)一般不直接签发服务, 而是签发一层二级CA, 由二级CA再去签发其他服务. 

我们先看如何验证证书链, 再来研究证书链的构成.

参考文章1中给出了对天猫证书链的验证方法, 不过那是windows下的, linux没法验证`cer`格式证书. 我在ubuntu16.04桌面版, 用chrome查看了一下`www.taobao.com`的证书链, 并导出为文件, 没后缀名.

![](https://gitee.com/generals-space/gitimg/raw/master/35402934e1075c9050ae5e0c0c498e0c.png)

```
$ ll
total 20
drwxr-xr-x  2 general general 4096 4月   9 09:03 ./
drwxr-xr-x 22 general general 4096 4月   5 13:52 ../
-rw-rw-r--  1 general general 1282 4月   9 09:02 Builtin Object Token_GlobalSign Root CA
-rw-rw-r--  1 general general 1616 4月   9 09:02 GlobalSign Organization Validation CA - SHA256 - G2
-rw-rw-r--  1 general general 3956 4月   9 09:03 _.tmall.com
```

证书层级分别为

1. 根证书: Builtin Object Token_GlobalSign Root CA

2. GlobalSign Organization Validation CA - SHA256 - G2

3. _.tmall.com

## 1. 验证天猫证书链

首先直接验证3个证书

```
$ openssl verify Builtin\ Object\ Token_GlobalSign\ Root\ CA 
Builtin Object Token_GlobalSign Root CA: OK
$ openssl verify GlobalSign\ Organization\ Validation\ CA\ -\ SHA256\ -\ G2 
GlobalSign Organization Validation CA - SHA256 - G2: OK
$ openssl verify _.tmall.com 
_.tmall.com: C = CN, ST = ZheJiang, L = HangZhou, O = "Alibaba (China) Technology Co., Ltd.", CN = *.tmall.com
error 20 at 0 depth lookup:unable to get local issuer certificate
```

可以看到, 系统直接信任前两个证书, 说明2级证书虽然由根证书签发, 但也默认加入了系统的信任列表中. 

然后我们用根证书去验证2级证书, 通过`-CAfile`选项指定父级证书.

```
$ openssl verify -CAfile Builtin\ Object\ Token_GlobalSign\ Root\ CA   GlobalSign\ Organization\ Validation\ CA\ -\ SHA256\ -\ G2 
GlobalSign Organization Validation CA - SHA256 - G2: OK
```

也成功, 说明2级证书的确是由根证书直接签发的.

~~但是验证第3级天猫的泛域名证书`_.tmall.com`就不行了. 用2级证书验证3级证书将得到如下错误.~~

这剧情不对啊, 用2级证书验证3级证书也能行啊.

```
$ openssl verify -CAfile GlobalSign\ Organization\ Validation\ CA\ -\ SHA256\ -\ G2  _.tmall.com 
_.tmall.com: OK
```

...没毛病, 不像参考文章1中所说需要合并根证书与2级证书才能通过验证, 不过还是要试一试.

```
$ cat Builtin\ Object\ Token_GlobalSign\ Root\ CA GlobalSign\ Organization\ Validation\ CA\ -\ SHA256\ -\ G2 > bundle.crt
$ openssl verify -CAfile bundle.crt _.tmall.com 
_.tmall.com: OK
```

也成功了...

## 2. 验证自签名证书

我们来做个比较复杂的实验吧.

首先生成根证书CA, 用它签发A, B两个中间证书, 再用A签发a证书, 整个证书链的层级关系如下

```
CA
├── A
│   └── a
├── B
```

按照如下步骤生成证书

```
## 首先生成根证书CA, 根证书不需要csr文件, 因为它不需要被签名
openssl req -new -x509 -days 36500 -extensions v3_ca -keyout CA.key -out CA.crt

## 然后生成二级CA A和B, 服务器证书a
openssl genrsa -out A.key 2048
openssl genrsa -out B.key 2048
openssl genrsa -out a.key 2048
openssl req -new -key A.key -out A.csr
openssl req -new -key B.key -out B.csr
openssl req -new -key a.key -out a.csr

## 用CA证书为A, B签发证书
openssl x509 -req -extensions v3_ca -CA CA.crt -CAkey CA.key -CAcreateserial -days 36500 -in A.csr -out A.crt
openssl x509 -req -extensions v3_ca -CA CA.crt -CAkey CA.key -CAcreateserial -days 36500 -in B.csr -out B.crt

## 用二级CA A为a密钥签名
openssl x509 -req -CA A.crt -CAkey A.key -CAcreateserial -days 36500 -in a.csr -out a.crt
```

> 注意, 每次生成`*.csr`文件时, `Common Name`的值都不要与签发者证书的`Common Name`一样. 比如A的CN值不能和CA的一样, 不然会有问题的.

### 2.1 验证根证书

验证自签发CA根证书时

```
$ openssl verify CA.crt
CA.crt: C = XX, L = Default City, O = Default Company Ltd, CN = 0.0.0.0
error 18 at 0 depth lookup:self signed certificate
OK
```

咳, csr信息只填了个`Common Name`...

它输出了`self signed certificate`, 表明openssl认为这是我们自签发的证书, 所以才有`error 18`. 

但这不是错误, 只是不被系统信任而已, 导入到系统的信任列表里就可以了, 关于如何导入等会再讨论. 

或者还有一种情况, 

### 2.2 验证证书链

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

### 2.3 信任根证书后验证

```
$ cp CA.crt /etc/pki/ca-trust/source/anchors/
$ update-ca-trust
```

重复上面的步骤试试.