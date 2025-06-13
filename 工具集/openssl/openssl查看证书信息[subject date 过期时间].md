# openssl查看证书信息

参考文章

1. [openssl查看证书信息](https://blog.51cto.com/wemux/5564119)

```
openssl x509 -noout -subject -issuer -dates -in server.crt 
```

可以通过`​openssl x509 --help 2>&1 | grep print`获取所有可查看的信息.

- noout: 不再输出证书本身的内容
- subject: 证书的主体(拥有者)名字, 一般为域名, 如`/CN=kubernetes`
    - 可以通过添加额外参数`-nameopt`以规定的格式打印, 如`-subject -nameopt RFC2253|oneline`
- issuer: 给当前证书签名的ca.crt的`subject`(即父级证书)
    - 如果当前证书本身就是根证书(没有人签名), 那么该值会等于`subject`值.
- dates: 生效时间(包含起始与终止两个时间)
- serial: 证书的序列号
- text: 证书内容(这个很长, 信息很多)


把PEM格式的证书转化成DER格式

```
​openssl x509 -in cert.pem -inform PEM -out cert.der -outform DER
```

把⼀个证书转化成CSR

```
​openssl x509 -x509toreq -in cert.pem -out req.pem -signkey key.pem
```

给⼀个CSR进⾏处理，颁发字签名证书，增加CA扩展项

```
​openssl x509 -req -in careq.pem -extfile openssl.cnf -extensions v3_ca -signkey key.pem -out cacert.pem
```

给⼀个CSR签名，增加⽤户证书扩展项

```
​openssl x509 -req -in req.pem -extfile openssl.cnf -extensions v3_usr -CA cacert.pem -CAkey key.pem -CAcreateserial
```

查看csr⽂件细节：

```
​openssl req -in my.csr -noout -text
```
