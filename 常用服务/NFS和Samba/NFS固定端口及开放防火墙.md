# NFS固定端口及开放防火墙

参考文章

1. [CentOS7安装配置 NFS](http://wangshengzhuang.com/2017/06/07/Linux/Linux%E5%9F%BA%E7%A1%80/CentOS%207%20%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AE%20NFS/)

2. [固定NFS启动端口便于iptables设置](https://blog.51cto.com/pizibaidu/1662428)

阿里云上搭建NFS, 云端局域网内部可连, 但是由于安全组的存在, 无法从外网挂载.

两个参考文章说的其实挺靠谱的, 但是不成功...先记录一下.