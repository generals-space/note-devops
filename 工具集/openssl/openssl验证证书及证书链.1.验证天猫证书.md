# openssl验证证书及证书链.1.验证天猫证书

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

```console
$ ll
total 20
drwxr-xr-x  2 general general 4096 4月   9 09:03 ./
drwxr-xr-x 22 general general 4096 4月   5 13:52 ../
-rw-rw-r--  1 general general 1282 4月   9 09:02 Builtin Object Token_GlobalSign Root CA
-rw-rw-r--  1 general general 1616 4月   9 09:02 GlobalSign Organization Validation CA - SHA256 - G2
-rw-rw-r--  1 general general 3956 4月   9 09:03 _.tmall.com
```

证书层级分别为

1. 根证书: Builtin Object Token_GlobalSign Root CA (以下将其重命名为`builtin.crt`)
2. GlobalSign Organization Validation CA - SHA256 - G2 (以下将其重命名为`global.crt`)
3. _.tmall.com (以下将其重命名为`tmall.crt`)

首先直接验证3个证书

```console
$ openssl verify builtin.crt 
builtin.crt: OK
$ openssl verify global.crt 
global.crt: OK
$ openssl verify tmall.crt 
tmall.crt: C = CN, ST = ZheJiang, L = HangZhou, O = "Alibaba (China) Technology Co., Ltd.", CN = *.tmall.com
error 20 at 0 depth lookup:unable to get local issuer certificate
```

可以看到, 系统直接信任前两个证书, 说明2级证书虽然由根证书签发, 但也默认加入了系统的信任列表中. 

然后我们用根证书去验证2级证书, 通过`-CAfile`选项指定父级证书.

```console
$ openssl verify -CAfile builtin.crt global.crt 
global.crt: OK
```

也成功, 说明2级证书的确是由根证书直接签发的.

现在用2级证书验证3级证书.

```console
$ openssl verify -CAfile global.crt tmall.crt 
tmall.crt: OK
```

...没毛病, 不像参考文章1中所说需要合并根证书与2级证书才能通过验证, 不过还是要试一试.

```console
$ cat builtin.crt global.crt > bundle.crt
$ openssl verify -CAfile bundle.crt tmall.crt 
tmall.crt: OK
```

也成功了...
