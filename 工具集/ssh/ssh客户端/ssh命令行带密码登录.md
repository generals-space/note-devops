# ssh命令行带密码登录

参考文章

1. [ssh命令带密码](https://blog.51cto.com/xhk777/2045121)

貌似没有其他办法...

```
sshpass -p 'xxx' ssh root@192.168.1.1
```

如果是首次登录目标主机, 可能会由于需要对ta的公钥输入`yes`, 但是`sshpass`却并不显示那段输出, 导致上述命令静默地失败.

此时需要指定不检查目标主机的公钥选项

```
sshpass -p 'xxx' ssh -o 'StrictHostKeyChecking no' root@192.168.1.1
```
