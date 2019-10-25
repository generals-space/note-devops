# Linux开机加载内核模块

参考文章

1. [Linux开机加载内核模块](https://www.jianshu.com/p/69e0430a7d20)

不建议使用`rc.local`

```
cat <<EOF > /etc/sysconfig/modules/k8s.modules
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4
modprobe br_netfilter
EOF
## 保证可执行
chmod 755 /etc/sysconfig/modules/k8s.modules

```
