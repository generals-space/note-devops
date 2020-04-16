## vpn服务适用于一些开源项目的编译工作, 有时无法走ss/proxy等代理的场景.
yum install -y ppp pptp pptpd pptp-setup

cat >> /etc/pptpd.conf << EOF
localip 192.168.1.1
remoteip 192.168.1.234-238,192.168.1.245
EOF

cat >> /etc/ppp/options.pptpd << EOF
ms-dns 8.8.8.8
ms-dns 8.8.4.4
EOF

## vpn 客户端账号配置
## pptpd 为 server 名称, 在 /etc/ppp/options.pptpd 中通过 name 字段配置.
cat >> /etc/ppp/chap-secrets << EOF
## * 表示接受来自所有 IP 的客户端
general pptpd 123456 * 
EOF

cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward=1
net.ipv4.tcp_syncookies= 0
EOF
sysctl -p

iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

systemctl start pptpd
