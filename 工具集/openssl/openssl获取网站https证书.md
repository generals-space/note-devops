# openssl获取网站https证书

参考文章

1. [How to save a remote server SSL certificate locally as a file](https://superuser.com/questions/97201/how-to-save-a-remote-server-ssl-certificate-locally-as-a-file)

2. [Displaying a remote SSL certificate details using CLI tools](https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools)

3. [如何用OpenSSL从https网站上导出SSL的CA证书?](https://blog.csdn.net/iteye_4639/article/details/82579715)

按照参考文章3中所说, 可以使用openssl的`s_client`子命令.

```
$ openssl s_client -showcerts -connect https://goproxy.onetool.net
getaddrinfo: Servname not supported for ai_socktype
connect:errno=0
```

网站地址不能是`https://`这种, 要使用**域名+端口**的形式, 如下

```
$ openssl s_client -showcerts -connect goproxy.onetool.net:443
CONNECTED(00000003)
depth=3 C = SE, O = AddTrust AB, OU = AddTrust External TTP Network, CN = AddTrust External CA Root
verify return:1
depth=2 C = US, ST = New Jersey, L = Jersey City, O = The USERTRUST Network, CN = USERTrust RSA Certification Authority
verify return:1
depth=1 C = CN, ST = Shanghai, O = "TrustAsia Technologies, Inc.", CN = TrustAsia RSA DV SSL Server CA
verify return:1
depth=0 OU = Domain Control Validated, OU = TrustAsia DV SSL SAN, CN = *.cdn.myqcloud.com
verify return:1
---
Certificate chain
 0 s:/OU=Domain Control Validated/OU=TrustAsia DV SSL SAN/CN=*.cdn.myqcloud.com
   i:/C=CN/ST=Shanghai/O=TrustAsia Technologies, Inc./CN=TrustAsia RSA DV SSL Server CA
-----BEGIN CERTIFICATE-----
MIIG2zCCBcOgAwIBAgIQOIgrGOyWTvRl2FC6aURcZjANBgkqhkiG9w0BAQsFADBw
MQswCQYDVQQGEwJDTjERMA8GA1UECBMIU2hhbmdoYWkxJTAjBgNVBAoTHFRydXN0
...省略
```

由于证书是外链式结构, 所以可能会有多个证书, `-----BEGIN CERTIFICATE-----`和`-----END CERTIFICATE-----`会有不只一对, ta们从0开始计数, 依次排序.

每个证书都有独立生效的域名, 上面的输出中, `CN`值为`*.cdn.myqcloud.com`, 那么可以将此证书命名为`cdn.myqcloud.com.crt`然后导入.

...但我明明请求的是`goproxy.onetool.net`, 输出中却没有一个是这个域名下的, 所以最终也没用上.
