# NFS与Samba的区别

## 相同点

NFS和Samba都可以作为共享目录, 且windows上都有相应的客户端工具挂载.

## 不同点

NFS的配置较为简单, Samba更为灵活.

比如NFS没有账户密码和权限机制, 只能指定共享给指定地址, 该地址上可访问的用户拥有的权限都是一样的. 所以一般只能用于内网共享, 在不安全的环境中, 应尽量避免使用NFS.