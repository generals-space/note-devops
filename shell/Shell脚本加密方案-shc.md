# Shell脚本加密方案-shc

参考文章

1. [采用gzexe\shc工具加密Shell脚本](https://www.cwj95.com/385.html)

当我们写的shell脚本，存在有敏感信息如账号密码，于是想加强脚本的安全性；还有不想让别人查看/修改您的shell核心代码等等情况。都可使用shc工具进行加密。
shc是一个脚本编译工具, 使用RC4加密算法, 它能够把shell程序转换成二进制可执行文件(支持静态链接和动态链接)。

[shc官网](http://www.datsi.fi.upm.es/~frosal/)
