# ssh config配置.1

参考文章

1. [ssh 别名登录小技巧](http://www.ttlsa.com/linux/ssh-config-aliases-server-access-tricks/)

`~/.ssh/config`文件内容如下

```
## Host只是登录别名
Host general
    ## HostName可以是域名也可以是IP
    HostName 12.34.56.78
    Port 22
    User root
    ## 可以决定是否使用密钥登录
    ## IdentityFile ~/.ssh/id_rsa.pub
```

之后可以以如下方式登录

```
ssh general
```

`.ssh/config`文件对应于`/etc/ssh/ssh_config`, 其中的配置也是相同的, 可以查看所有可用选项及选项值.

另外, 对于`.ssh`目录下的文件, 需要保证权限足够小, 最好将其权限设置为`600`, 否则可能会有如下情况发生.

```
$ ssh general
Bad owner or permissions on /home/general/.ssh/config
```
