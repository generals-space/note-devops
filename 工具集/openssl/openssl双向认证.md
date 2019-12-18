# openssl双向认证

https网站使用ssl证书的目的是保护客户端, 所以只需要服务端部署server.crt, 客户端(一般是浏览器)会根据本地内置的ca验证其是否合法, 同时用户也有权选择忽略不合法的证书.

但是类似kuber, apiserver和kubectl交互用的是双向认证, 即apiserver会对kubectl客户端的请求验证其证书, kubectl也会反过来验证apiserver的证书的合法性. 且与https网站不同的是, apiserver和kubectl在程序中写明, 只要证书不合法就拒绝请求, 所以可以直接通过验证证书合法性确认用户身份.
