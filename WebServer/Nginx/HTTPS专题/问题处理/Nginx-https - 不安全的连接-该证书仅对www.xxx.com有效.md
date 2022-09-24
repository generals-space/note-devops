# Nginx-https不安全的连接-该证书仅对www.xxx.com有效


使用第三方认证机构进行证书签名时, 需要指定要使用的顶级域名或二级域名. 访问目标网站与配置的证书不符时, 会显示"不安全的连接", 情况大致如下.

![](https://gitee.com/generals-space/gitimg/raw/master/cce096442576ff9b29222879af44b7f7.png)

![](https://gitee.com/generals-space/gitimg/raw/master/593f860cbebbb8704177c9ff6128154d.jpg)

![](https://gitee.com/generals-space/gitimg/raw/master/d11b57c48a4e2a1cb8e1fb8833a11ce3.jpg)

可以看到chrome与firefox中都提到该域名的证书是为`databegin.com`申请的, 虽然在服务器上配置了`www.databegin.com`也使用这个证书, 但由于没有为`www`这个子域名进行签名, 所以浏览器认为此网站不安全.
