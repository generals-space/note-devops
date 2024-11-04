# apt update - The certificate is NOT trusted.

参考文章

1. [Linux 报错Certificate verification failed: The certificate is NOT trusted.](https://www.morfans.cn/archives/3339)

## 问题描述

ubuntu:22.04

先执行如下命令安装vim

```
apt update
apt install vim
```

然后更改apt源为阿里云后, 再次update出错

```log
root@3020e80d4763:/etc/apt# apt update
Ign:1 https://mirrors.aliyun.com/ubuntu jammy InRelease
## ...省略
Err:1 https://mirrors.aliyun.com/ubuntu jammy InRelease
  Certificate verification failed: The certificate is NOT trusted. The certificate issuer is unknown.  Could not handshake: Error in the certificate verification. [IP: 192.168.9.129 8888]
Err:4 https://mirrors.aliyun.com/ubuntu jammy-backports InRelease
  Certificate verification failed: The certificate is NOT trusted. The certificate issuer is unknown.  Could not handshake: Error in the certificate verification. [IP: 192.168.9.129 8888]
Reading package lists... Done
## ...省略
All packages are up to date.
W: https://mirrors.aliyun.com/ubuntu/dists/jammy/InRelease: No system certificates available. Try installing ca-certificates.
## ...省略
W: Failed to fetch https://mirrors.aliyun.com/ubuntu/dists/jammy/InRelease  Certificate verification failed: The certificate is NOT trusted. The certificate issuer is unknown.  Could not handshake: Error in the certificate verification. [IP: 192.168.9.129 8888]
## ...省略
W: Some index files failed to download. They have been ignored, or old ones used instead.
```

## 处理方法

看着像是系统证书的问题, 按照参考文章1所说, 应该在更换源之前, 先安装`ca-certificates`依赖(直接和vim一起装), 装完再用vim替换源update即可.