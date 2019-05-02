# SSH服务配置

## 1. 禁止某些用户远程登陆

根据需要在`/etc/ssh/sshd_config`添加

```
AllowUsers 允许登陆的用户名
AllowGroups 允许登陆的组名
DenyUsers 禁止登陆的用户名
```