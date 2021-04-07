# sshd关闭除DNS反解缩短登录时间

参考文章

1. [SSH登录过慢怎么办？取消ssh的DNS反解](http://www.zxsdw.com/index.php/archives/1078/)

ssh登陆某些服务器,会发生需要等到十来秒才提示输入密码下现象,其实这个是sshd做的一个配置上的修改引起的.

使用的Linux用户可能觉得用SSH登陆时为什么反映这么慢, 有的可能要几十秒才能登陆进系统. 其实这是由于默认sshd服务开启了DNS反向解析, 如果你的sshd没有使用域名等来作为限定时, 可以取消此功能. 

编辑`/etc/ssh/sshd_config`文件, 将 `# UseDNS yes`改为`UseDNS no`(没有的话自行添加)然后重启sshd服务即可.
