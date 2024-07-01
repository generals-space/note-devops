# Linux应用技巧-passwd行内修改密码

参考文章

1. [如何使用不同的方式更改 Linux 用户密码](https://zhuanlan.zhihu.com/p/56313895)

CentOS

```bash
echo "new_password" | passwd --stdin root
```

Ubuntu

```bash
echo "root:new_password" | chpasswd
```
