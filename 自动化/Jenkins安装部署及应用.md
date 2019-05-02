# Jenkins 安装部署

[官方文档](https://wiki.jenkins-ci.org)

### 1. 修改admin用户密码

参考文章

[Jenkins进阶系列之——11修改Jenkins用户的密码](http://blog.csdn.net/wangmuming/article/details/22925931)

有时忘记admin用户的密码, 或者在安装后Jenkins直接以admin权限执行并未创建新用户, 但重启Jenkins后会提示输入某用户的账号密码. 此时需要手动修改.

Jenkins并没有使用数据库, 其专有用户的数据存放在`$JENKINS_HOME/users/用户名/config.xml`文件中(若没有设置`$JENKINS_HOME`环境变量, 可以查看启动jenkins时的用户目录下是否存在`.jenkins`目录). 编辑它

```xml
<hudson.security.HudsonPrivateSecurityRealm_-Details>
    <passwordHash>#jbcrypt:$2a$10$DdaWzN64JgUtLdvxWIflcuQu2fgrrMSAMabF5TSrGK5nXitqK9ZMS</passwordHash>
</hudson.security.HudsonPrivateSecurityRealm_-Details>
```

将`passwordHash`字段设置为上述代码中的值, **注意前后不能有空格**.

重启Jenkins, login界面输入`admin`,`111111`即可登陆.

### 2. Jenkins 关闭, 重启

访问对应的Jenkins地址, 根据提示操作即可. 需要登陆.

```
## 关闭
localhost:8080/exit
## 重启
localhost:8080/restart
## 重新加载...不太好使
localhost:8080/reload
```
