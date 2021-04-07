# ssh_exchange_identification read Connection reset by peer

```console
$ ssh 用户名@ip地址
ssh_exchange_identification: read: Connection reset by peer
```

情境描述: ssh方式登陆, 输入密码后被拒绝

可能原因: 防火墙, hosts.deny都有可能是阻止的原因, 这种情况下一般不是验证本身的问题.
