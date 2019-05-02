# Linux导入证书

参考文章

1. [CentOS导入CA证书](https://blog.csdn.net/rznice/article/details/52250397)

2. [linux系统导入CA证书](https://blog.csdn.net/ziyouwayj/article/details/36371747)

与windows不同, linux系统下的证书一般是`pem`格式的, 且自带的信任列表随`ca-certificates`软件包一起加入到系统中.

## 1. CentOS 

把`ca.crt`放到`/etc/pki/ca-trust/source/anchors`目录下, 再执行`update-ca-trust`命令, 就可以更新当前系统所信任的证书.

之后所有由此根证书签发的子证书都会被信任.
