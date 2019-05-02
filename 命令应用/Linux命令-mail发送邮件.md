# Linux命令-mail发送邮件

参考文章

1. [Linux下使用mail命令发送邮件](http://www.mzone.cc/article/317.html)

2. [Linux mail 命令参数](https://www.cnblogs.com/toowang/p/3920465.html)

3. [Linux---mail命令安装](https://blog.csdn.net/moonhmilyms/article/details/25307957)

linux下有`mail`命令, 可以直接在命令行发送邮件(不过容易被判断为垃圾邮件, 因为可能没有合法的邮件地址). 

> 使用`mail`命令, 需要先安装`mailx`和`sendmail`包, 并且必须先将`sendmail`服务启动.

```
yum install -y mailx sendmail
systemctl start sendmail
```

使用方式为

```shell
mail -s '邮件主题' xxx@qq.com
正文内容
正文内容
```

`-s`指定邮件主(标)题, 必须是`mail`命令的第一个参数

`xxx@qq.com`指定收件人的地址

回车之后可以书写正文, 正文中可以换行, 连按两次`Ctrl + c`取消编辑, `Ctrl + d`会结束输入并发送(也有说这一步后会提示输入邮件抄送地址, 按回车结束后发送).

或是发送文件(管道什么的同理)

```shell
mail -s "Hello from mzone.cc by file" admin@mzone.cc < mail.txt
```

> linux下在终端交互式命令中输入内容时, 输入错了想用退格键删除会出现`^H`这种乱码. 这种情况下发送的邮件, 收件人的邮箱中不会看到内容, 而是会有一个`.bin`附件, 里面才是带有乱码的内容...
