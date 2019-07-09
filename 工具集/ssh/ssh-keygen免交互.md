# ssh-keygen免交互

参考文章

1. [ssh第一次输入免yes 和ssh-keygen免交互](https://my.oschina.net/honglongwei/blog/719198)

有时在脚本中需要生成密钥对, 此操作需要用到ssh-keygen命令. 但ssh-keygen需要手动输入私钥密码和密钥路径.

```
ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): ## 回车
Enter passphrase (empty for no passphrase): ## 回车
Enter same passphrase again: ## 回车
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Urz8bwevzYTOrQ4GBC4oOzq5yOkxXV0cxkvirXt0LkU root@65ffaef2e17d
The key's randomart image is:
+---[RSA 2048]----+
|      . .o       |
|   . . +oo.      |
|. . . o Bo.      |
| o   ..=.+ E     |
|o    ...S .      |
|.o. .  o + o..   |
|+o .    o B .o.  |
|oo+    . + *.=o  |
|++      . .oB++  |
+----[SHA256]-----+
```

如果需要使用免交互模式需要用到ssh-keygen的`-P`(指定私钥密码)和`-f`指定密钥路径.

```
# ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa
Generating public/private rsa key pair.
Created directory '/root/.ssh'.
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:w6qc+NR4deqTg7rR1b8kxhsZBS2SwKH3zMx9O0p59ZQ root@65ffaef2e17d
The key's randomart image is:
+---[RSA 2048]----+
|     .oo ...     |
|     .. o ...    |
|    . .  . ..    |
|     . B o .    .|
|        S = . .E.|
|     + + = * o o |
|    + =...O *   .|
|   + =..+o B o   |
|  ..Bo  .oo .    |
+----[SHA256]-----+
```
