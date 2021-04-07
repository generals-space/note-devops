# xshell ssh服务器拒绝了密码 请再试一次

问题描述: XShell连接虚拟机的ssh, 显示"ssh服务器拒绝了密码 请再试一次", 一直让输入密码.

原因分析: 可能在`/etc/ssh/sshd_config`中存在这样一句:

```
# Authentication:
LoginGraceTime 120
# PermitRootLogin without-password  ##注意, 这行是重点, 需要注释掉!!!
StrictModes yes
```

解决方法: 将`without-password`这行注释掉即可
