# sysctl命令详解

`sysctl -a`: 查看sysctl所有可用字段.

`sysctl -w net.ipv4.ip_forward=1`: 临时设置目标字段的值, 但不会永久保持, 系统重启即会失效.

`sysctl -p`: 可以加载`/etc/sysctl.conf`文件中配置的字段. 如果事先使用`-w`临时修改了某个字段(如a)的值, 执行`-p`时, 只有当`/etc/sysctl.conf`文件中包含字段a, 才会覆盖这个临时值, 否则将不会影响`-w`设置的字段.

`sysctl --system`: 与`-p`作用相似, 不过ta加载的文件更多, 包括`/run/sysctl.d/*.conf`, `/etc/sysctl.d/*.conf`..`/etc/sysctl.conf`等, 有序, 后者会覆盖前者. 系统重启加载的顺序也是如此.
