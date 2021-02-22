# sshd_config禁止密码登录

参考文章

1. [How-to: Disable ssh password authentication and enable private key authentication](https://discussions.apple.com/thread/7488509)
2. [Disable ssh password authentication on High Sierra](https://apple.stackexchange.com/questions/315881/disable-ssh-password-authentication-on-high-sierra)

禁止密码登录, 只设置`PasswordAuthentication no`不生效, 按照参考文章1中所说, 加上`UsePAM no`也不生效, 需要再加上`ChallengeResponseAuthentication no`, 如下

```
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```

同时配置密钥登录

```
RSAAuthentication yes
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```
